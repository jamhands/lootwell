--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.MainMenu = {}; -- adds MainMenu table to addon namespace

local MainMenu = core.MainMenu;
local UIConfig;

--------------------------------------
-- Config functions
--------------------------------------
function MainMenu:Toggle()
	local menu = UIConfig or MainMenu:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

-- function Config:CreateButton(point, relativeFrame, relativePoint, yOffset, text)
-- 	local btn = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate");
-- 	btn:SetPoint(point, relativeFrame, relativePoint, 0, yOffset);
-- 	btn:SetSize(140, 40);
-- 	btn:SetText(text);
-- 	btn:SetNormalFontObject("GameFontNormalLarge");
-- 	btn:SetHighlightFontObject("GameFontHighlightLarge");
-- 	return btn;
-- end

function MainMenu:CreateMenu()
	-- UIConfig = CreateFrame("Frame", "LW_MainMenuFrame", UIParent, "BasicFrameTemplateWithInset")
	UIConfig = MainMenuTemplate
	print(UIConfig)
	
    UIConfig:SetSize(1200, 800)
    UIConfig:SetPoint("CENTER", UIParent, "CENTER")
	print("test")

    UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY")
    UIConfig.title:SetFontObject("GameFontHighlight")
    UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0)
	UIConfig.title:SetText("LootWell")
	print("test2")
	
	MainMenuLeftPanelButton1FontString:SetText("Guild Members")
	MainMenuLeftPanelButton2FontString:SetText("Gear")
	MainMenuLeftPanelButton3FontString:SetText("Loot History")

	MainMenu:SetUpLeftPanelEvents()
	
	UIConfig:Hide();
	return UIConfig;
end

function MainMenu:SetUpLeftPanelEvents()
	print("Test!")
	MainMenuLeftPanelButton1:SetScript("OnClick", MainMenu.OnGuildMembersButtonClick)
end

function MainMenu:OnGuildMembersButtonClick()
	print("You clicked Guild Members!")
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

--------------------------------
-- Roster Menu
--------------------------------

local classIcons = {
	["Warrior"] = "Interface\\ICONS\\INV_Sword_27.blp",
	["Rogue"] = "Interface\\ICONS\\INV_ThrowingKnife_04.blp",
	["Paladin"] = "Interface\\ICONS\\INV_Hammer_01.blp",
	["Priest"] = "Interface\\ICONS\\INV_Staff_30.blp",
	["Druid"] = "Interface\\ICONS\\Ability_Druid_Maul.blp",
	["Hunter"] = "Interface\\ICONS\\INV_Weapon_Bow_07.blp",
	["Shaman"] = "Interface\\ICONS\\Spell_Nature_BloodLust.blp",
	["Mage"] = "Interface\\ICONS\\INV_Staff_13.blp",
	["Warlock"] = "Interface\\ICONS\\Spell_Nature_Drowsy.blp"
};

local sortedRoster = {}
local rosterFrames = {}

function MainMenu:BuildRosterPage()
	sortedRoster = core.Util:SortTableByOrder(core.Data.roster, core.Data.defaultRosterSortOrder)

	for key, value in ipairs(rosterFrames) do
		print("Hiding roster item: " .. key)
		MainMenu:HideRosterItem(key)
	end

	-- Set scroll child size
	MainMenuBodyScrollFrame.scrollChild:SetSize(860, math.max(725, #sortedRoster * 30))

	for key, value in ipairs(sortedRoster) do
		local rosterItem = MainMenu:BuildRosterItem(sortedRoster[key], key)
		print("Added " .. value.name)
	end
	-- local rosterItem = MainMenu:BuildRosterItem(sortedRoster[1])
	-- print(rosterItem)
	-- rosterItem:SetParent(MainMenuBodyScrollFrame.scrollChild)
	-- rosterItem:SetParent(UIConfig)
	-- rosterItem:Show()
	-- print(rosterItem:GetSize())
	-- print(rosterItem:GetNumPoints())
	-- print("Left " .. rosterItem:GetLeft())
	-- print("Right " .. rosterItem:GetRight())
	-- print("Top " .. rosterItem:GetTop())
	-- print("Bottom " .. rosterItem:GetBottom())
	-- print(MainMenuBodyScrollFrame.scrollChild:GetChildren())
	-- local kids = { MainMenuBodyScrollFrame.scrollChild:GetChildren() };

	-- for _, child in ipairs(kids) do
	-- 	print(child)
	-- end

end

-- Must not call this function on a position greater than 1 beyond the current size
function MainMenu:BuildRosterItem(member, position)
	local rosterItem
	print ("Key = " .. position)
	if not rosterFrames[position] then
		print("Creating new frame for " .. position)
		rosterItem = CreateFrame("Frame", position .. "RosterItem", MainMenuBodyScrollFrame.scrollChild, "RosterMemberListItem")
		-- Set position
		rosterItem:SetPoint("TOPLEFT", MainMenuBodyScrollFrame.scrollChild, "TOPLEFT", 0, (position - 1) * -30)
		rosterFrames[position] = rosterItem
	else
		rosterItem = rosterFrames[position]
	end

	-- Fill in text values
	rosterItem.name:SetText(member.name)
	rosterItem.rank:SetText(member.rank)
	rosterItem.role:SetText(member.role)
	rosterItem.attendance:SetText(member.attn)

	-- Choose icon
	print("Class for " .. member.name .. ": " .. member.class)
	print(classIcons[member.class])
	-- SetPortraitToTexture(rosterItem.classIcon.texture, classIcons[member.class]) -- TODO optional function to make edges not stick out?
	rosterItem.classIcon.texture:SetTexture(classIcons[member.class])

	rosterItem:Show()
	return rosterItem
end

function MainMenu:HideRosterItem(position)
	if not rosterFrames[position] then
		return
	end
	rosterFrames[position]:Hide()
	print("Roster item hidden: " .. position)
end