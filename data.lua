
local _, core = ...;
core.Data = {}

local Data = core.Data
Data.roster = {}


function Data:QueryForItem(id)
    itemId = tonumber(id)
    item = Item:CreateFromItemID(itemId)
    item:ContinueOnItemLoad(function()
        print(item:GetItemLink())
        --local _, itemLink = GetItemInfo(id)
        --print(itemLink)
    end)
end

function Data:QueryForItemByLink(link)
    item = Item:CreateFromItemLink(link)
    item:ContinueOnItemLoad(function()
        print(item:GetItemLink())
        print(item:GetItemName())
        --local _, itemLink = GetItemInfo(id)
        --print(itemLink)
    end)
end

-- function Data:AddMember(memberName)
--     --Name provided must be a member of current guild.
--     guildInfo = {GetGuildRosterInfo(memberName)}
--     for i=1,
-- end

function Data:PrintKeys(o)
    for key,value in pairs(o) do
        print("found member" .. key)
    end
end

-------------------------------------
--GUILD INFO
-------------------------------------

function Data:RetrieveGuildInfo()
    if Data.GuildMembers == nil then
        Data.GuildMembers = {}
    end
    local numGuildMembers = GetNumGuildMembers()
    if numGuildMembers ~= nil then
        for i=1,numGuildMembers do
            local guildMember = Data:RetrieveGuildMember(i)
            Data.GuildMembers[guildMember.name] = guildMember
        end
    end
end

function Data:RetrieveGuildMember(i)
    local results = {GetGuildRosterInfo(i)}
    local guildMember = {}
    guildMember.name = Data:SplitNameFromServer(results[1])
    guildMember.rank = results[2]
    guildMember.rankIndex = results[3]
    guildMember.level = results[4]
    guildMember.class = results[5]
    return guildMember
end

function Data:PrintGuildMemberNames()
    if Data.GuildMembers ~= nil then
        local count = 0
        for k, v in pairs(Data.GuildMembers) do
            print(k, Data:SplitNameFromServer(v["name"]), v["rank"], v["rankIndex"], v["level"], v["class"])
            count = count + 1
        end
        if count == 0 then
            print("No guild members!")
        end
    end
end

function Data:SplitNameFromServer(name)
    local dashLoc = name:find("-")
    if dashLoc == nil then
        return name
    end
    return name:sub(0, dashLoc - 1)
end

-------------------------------
-- ROSTER MANAGEMENT
-------------------------------

-- Not to be mistaken with guild, these functions are responsible for adding or removing members to/from the roster.
-- At the moment just supporting one roster but will eventually support multiple.

function Data:AddToRoster(name)
    -- Try to find name in guild members
    if Data.roster[name] ~= nil then
        print(name .. " already present in roster!")
        return
    end
    if Data.GuildMembers[name] ~= nil then
        Data.roster[name] = Data:BuildRosterMember(Data.GuildMembers[name])
        print("Inserted " .. name .. " into roster!")
    else
        print("Unable to find member in guild roster")
    end
end

function Data:BuildRosterMember(guildMember)
    local rosterMember = {}
    rosterMember.name = Data:SplitNameFromServer(guildMember.name)
    rosterMember.rank = guildMember.rank
    rosterMember.rankIndex = guildMember.rankIndex
    rosterMember.level = guildMember.level
    rosterMember.class = guildMember.class
    rosterMember.gear = {}
    return rosterMember
end

function Data:PrintRoster()
    if Data.roster ~= nil then
        local count = 0
        for k, v in pairs(Data.roster) do
            print(k, v["name"], v["rank"], v["rankIndex"], v["level"], v["class"])
            count = count + 1
        end
        if count == 0 then
            print("No roster members!")
        end
    end
end

function Data:RemoveFromRoster(name)
    -- Try to find name in guild members
    if Data.roster[name] ~= nil then
        Data.roster[name] = nil
        print(name .. " removed from roster!")
    else
        print("Unable to find member in roster")
    end
end

-- Assumes that arguments are rosterMember objects
function Data.defaultRosterSortOrder(member1, member2)
    if not member1 then return false end
    if not member2 then return false end
    if member1.rankIndex ~= member2.rankIndex
    then
        return member1.rankIndex < member2.rankIndex
    end
    if member1.class ~= member2.class
    then
        return member1.class < member2.class
    end
    return member1.name < member2.name
end

------------------------------------
-- GEAR MANAGEMENT
------------------------------------

function Data:AddGearToMember(rosterMember, itemId)
    print(rosterMember .. " " .. itemId)
    print(table)
    if Data.roster[rosterMember] == nil then
        print("Unable to find member in roster")
        return
    end

    if Data.roster[rosterMember].gear == nil then
        Data.roster[rosterMember].gear = {}
    end
    table.insert(Data.roster[rosterMember].gear, itemId)
end

function Data:ListGear(rosterMember)
    if Data.roster[rosterMember] == nil then
        print("Unable to find member in roster")
        return
    end
    if Data.roster[rosterMember].gear ~= nil then
        local count = 0
        for k, v in pairs(Data.roster[rosterMember].gear) do
            print(v)
            count = count + 1
        end
        if count == 0 then
            print("No gear for " .. rosterMember .. "!")
        end
    end
end