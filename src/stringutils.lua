local find = string.find
local insert = table.insert
local sub = string.sub

function string.explode(div, str)
    if (div=='') then return false end
    local pos,arr = 0,{}
    -- for each divider found
    for st,sp in function() return find(str,div,pos,true) end do
        insert(arr,sub(str,pos,st-1)) -- Attach chars left of current divider
        pos = sp + 1 -- Jump past current divider
    end
    insert(arr,sub(str,pos)) -- Attach chars right of last divider
    return arr
end