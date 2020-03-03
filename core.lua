-- An addon designed to track loot distribution in a guild. The primary focuses 
-- will be ease of decision during raids and import/export functionality.

local _, core = ...; -- Namespace

--------------------------------------
-- Custom Slash Command
--------------------------------------
core.commands = {
	["menu"] = core.MainMenu.Toggle, -- this is a function (no knowledge of MainMenu object)
	
	["help"] = function()
		print(" ");
		core:Print("List of slash commands:")
		core:Print("|cff00cc66/lw menu|r - shows main menu");
		core:Print("|cff00cc66/lw help|r - shows help info");
		print(" ");
	end,

	["item"] = function(...)
		args = ...
		core.Data:QueryForItemByLink(args)
	end,

	["members"] = function(...)
		core.Data:RetrieveGuildInfo(...)
		core.Data:PrintGuildMemberNames()
	end,

	["roster"] = {
		["add"] = function(...)
			core.Data:AddToRoster(...)
			core.MainMenu:BuildRosterPage()
		end,
		["list"] = core.Data.PrintRoster,
		["remove"] = function(...)
			core.Data:RemoveFromRoster(...)
			core.MainMenu:BuildRosterPage()
		end,
	},

	["gear"] = {
		["add"] = function(...)
			core.Data:AddGearToMember(...)
		end,
		["list"] = function (...)
			core.Data:ListGear(...)
		end,
		["remove"] = function(...)
			core.Data:RemoveFromRoster(...)
		end,

	},
	
	["example"] = {
		["test"] = function(...)
			core:Print("My Value:", tostringall(...));
		end
	}
};

local function HandleSlashCommands(str)	
	if (#str == 0) then	
		-- User just entered "/lw" with no additional args.
		core.commands.help();
		return;		
	end	
	
	local args = {};
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end
	
	local path = core.commands; -- required for updating found table.
	
	for id, arg in ipairs(args) do
		if (#arg > 0) then -- if string length is greater than 0.
			arg = arg:lower();			
			if (path[arg]) then
				if (type(path[arg]) == "function") then				
					-- all remaining args passed to our function!
					path[arg](select(id + 1, unpack(args))); 
					return;					
				elseif (type(path[arg]) == "table") then				
					path = path[arg]; -- another sub-table found!
				end
			else
				-- does not exist!
				core.commands.help();
				return;
			end
		end
	end
end

function core:Print(...)
    -- local hex = select(4, self.Config:GetThemeColor());
    -- local prefix = string.format("|cff%s%s|r", hex:upper(), "Aura Tracker:");	
    local prefix = ""
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

-- WARNING: self automatically becomes events frame!
function core:init(event, name)
	if (name ~= "lootwell") then return end 

	-- allows using left and right buttons to move through chat 'edit' box
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false);
	end
	
	----------------------------------
	-- Register Slash Commands!
	----------------------------------
	SLASH_RELOADUI1 = "/rl"; -- new slash command for reloading UI
	SlashCmdList.RELOADUI = ReloadUI;

	SLASH_FRAMESTK1 = "/fs"; -- new slash command for showing framestack tool
	SlashCmdList.FRAMESTK = function()
		LoadAddOn("Blizzard_DebugTools");
		FrameStackTooltip_Toggle();
	end

	SLASH_Lootwell1 = "/lw";
	SlashCmdList.Lootwell = HandleSlashCommands;
	
    core:Print("Welcome back", UnitName("player").."!");
end

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", core.init);