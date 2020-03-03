--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Util = {}; -- adds MainMenu table to addon namespace

local Util = core.Util;

--------------------------------------
-- Sorting Functions
--------------------------------------

function Util:SortTableByOrder(tableToSort, order)
    -- Validate args
    if type(tableToSort) ~= "table"
    then
        return nil
    end
    local sortOrder = Util.DefaultSortOrder
    if type(order) == "function"
    then
        sortOrder = order
    end

    -- Sort table on "sortOrder" function
    local arrayToSort = {}
    for key, value in pairs(tableToSort) do table.insert(arrayToSort, value) end
    table.sort(arrayToSort, sortOrder)
    return arrayToSort
end

function Util:DefaultSortOrder(arg1, arg2)
    return arg1 < arg2
end