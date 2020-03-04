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
	MainMenu:SetUpRosterPageEvents()
	MainMenu:SetUpGearPageEvents()

	MainMenu:AddPage("roster", GuildMembersPage)
	MainMenu:AddPage("gear", GearPage)
	MainMenu:ChangePage("roster")

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

function MainMenu:SetUpRosterPageEvents()
	GuildMembersPage.gearButton:SetScript("OnClick", MainMenu.handleGearButtonClick)
end

function MainMenu:SetUpGearPageEvents()
	GearPage.backButton:SetScript("OnClick", MainMenu.handleBackButtonClick)
end

--------------------------------
-- Routing Functions
--------------------------------

local pageTable = {}
local activePage = nil

function MainMenu:AddPage(name, page)
	if pageTable[name] == nil then
		pageTable[name] = page
	end
end

function MainMenu:ChangePage(name)
	if pageTable[name] ~= nil then
		if activePage ~= nil then
			activePage:Hide()
		end
		activePage = pageTable[name]
		activePage:Show()
	end
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
	GuildMembersPageScrollFrame.scrollChild:SetSize(860, math.max(700, #sortedRoster * 30))

	for key, value in ipairs(sortedRoster) do
		local rosterItem = MainMenu:BuildRosterItem(sortedRoster[key], key)
		print("Added " .. value.name)
	end

	MainMenu:ClearSelectedRosterMember()
end

-- Must not call this function on a position greater than 1 beyond the current size
function MainMenu:BuildRosterItem(member, position)
	local rosterItem
	print ("Key = " .. position)
	if not rosterFrames[position] then
		print("Creating new frame for " .. position)
		rosterItem = CreateFrame("Button", position .. "RosterItem", GuildMembersPageScrollFrame.scrollChild, "RosterMemberListItem")
		-- Set position
		rosterItem:SetPoint("TOPLEFT", GuildMembersPageScrollFrame.scrollChild, "TOPLEFT", 0, (position - 1) * -30)
		rosterFrames[position] = rosterItem
		rosterItem:RegisterForClicks("AnyUp")
		rosterItem:SetScript("OnClick", MainMenu.handleRosterItemClick)
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

function MainMenu.handleRosterItemClick(self, button, down)
	-- On m1 button up
	if button == "LeftButton" and not down then
		MainMenu:SetSelectedRosterMember(self)
	end
end

local selectedRosterMember = nil
local selectedRosterWidget = nil

function MainMenu:SetSelectedRosterMember(widget)
	MainMenu:ClearSelectedRosterMember()
	selectedRosterWidget = widget
	selectedRosterMember = widget.name:GetText()
	print(selectedRosterMember)
	selectedRosterWidget:LockHighlight()
end

function MainMenu:ClearSelectedRosterMember()
	if selectedRosterWidget ~= nil then
		-- Unset the current widget
		selectedRosterWidget:UnlockHighlight()
	end
	selectedRosterWidget = nil
	selectedRosterMember = nil
end

function MainMenu.handleGearButtonClick(self, button, down)
	-- On m1 button up
	if button == "LeftButton" and not down then
		MainMenu:BuildGearPage(selectedRosterMember)
		MainMenu:ChangePage("gear")
	end
end

----------------------------------
-- Gear Page Functions
----------------------------------

function MainMenu.handleBackButtonClick(self, button, down)
	-- On m1 button up
	if button == "LeftButton" and not down then
		MainMenu:ChangePage("roster")
	end
end

local sortedGear = nil
local gearFrames = {}

function MainMenu:BuildGearPage(member)
	local gearList = core.Data:BuildGearDetails(member)
	sortedGear = core.Util:SortTableByOrder(gearList, core.Data.defaultGearSortOrder)

	for key, value in ipairs(gearFrames) do
		print("Hiding gear item: " .. key)
		MainMenu:HideGearItem(key)
	end

	-- Set scroll child size
	GearPageScrollFrame.scrollChild:SetSize(860, math.max(700, #sortedGear * 30))

	for key, value in ipairs(sortedGear) do
		local gearItem = MainMenu:BuildGearItem(sortedGear[key], key)
		print("Added " .. value.itemId)
	end

	MainMenu:ClearSelectedRosterMember()
end

-- Must not call this function on a position greater than 1 beyond the current size
function MainMenu:BuildGearItem(item, position)
	local gearItem
	print ("Key = " .. position)
	if not gearFrames[position] then
		print("Creating new frame for " .. position)
		gearItem = CreateFrame("Button", position .. "GearItem", GearPageScrollFrame.scrollChild, "GearListItem")
		-- Set position
		gearItem:SetPoint("TOPLEFT", GearPageScrollFrame.scrollChild, "TOPLEFT", 0, (position - 1) * -30)
		gearFrames[position] = gearItem
		-- rosterItem:RegisterForClicks("AnyUp")
		-- rosterItem:SetScript("OnClick", MainMenu.handleRosterItemClick)
	else
		gearItem = gearFrames[position]
	end

	-- Fill in text values
	gearItem.name:SetText(item.itemId)
	gearItem.rcvdOn:SetText(item.rcvdOn)
	gearItem.source:SetText(item.source)
	gearItem.notes:SetText(item.notes)

	-- Choose icon
	-- SetPortraitToTexture(rosterItem.classIcon.texture, classIcons[member.class]) -- TODO optional function to make edges not stick out?
	gearItem.itemIcon.texture:SetTexture(item.icon)

	gearItem:Show()
	return gearItem
end

function MainMenu:HideGearItem(position)
	if not gearFrames[position] then
		return
	end
	gearFrames[position]:Hide()
	print("Gear item hidden: " .. position)
end