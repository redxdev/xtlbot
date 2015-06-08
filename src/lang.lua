local require = require
local setmetatable = setmetatable
local print = print

local config = require("config.config")

local strings = {}
local lang = {}

local function lang_index(t, key)
    if strings[key] then
        return strings[key]
    end

    if config.debug then
        print("Loading language strings for " .. key)
    end

    strings[key] = require("config.lang." .. key)
    return strings[key]
end
setmetatable(lang, { __index = lang_index })

return lang