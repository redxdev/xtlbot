-- This plugin provides the ability to use mod commands through the bot
local print = print
local require = require
local tonumber = tonumber

local commands = require("src.commands")
local core = require("src.core")
local lang = require("src.lang")

local plugin = {}

local function cmd_mod(user, args)
    if #args ~= 1 then
        core.send_to_user(user.name, "!mod <user>")
        return
    end

    local target = args[1]
    core.send(".mod " .. target)
    core.send_to_user(user.name, lang.mod_commands.set_mod:format(target))
    print(user.name .. " set " .. target .. " as a twitch mod")
end

function plugin.init()
    commands.register("mod", "set a user as a twitch mod", cmd_mod, "twitch.mod")
end

return plugin