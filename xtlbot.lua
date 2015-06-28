-- xtlbot main
-- call this file via "lua xtlbot.lua"
local require = require
local print = print

local function file_exists(name)
    local f=io.open(name,"r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

if not file_exists("config/config.lua") then
    print "The main configuration file (config/config.lua) is missing! Run the configuration script."
    print "Exiting!"
    return
end

if not file_exists("config/plugins.lua") then
    print "The plugin configuration file (config/plugins.lua) is missing! Run the configuration script."
    print "Exiting!"
    return
end

local core = require("src.core")
core.init()