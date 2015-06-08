local print = print
local require = require
local pairs = pairs

local commands = require("src.commands")
local core = require("src.core")
local users = require("src.users")
local lang = require("src.lang")

local plugin = {}

local function cmd_help(user, args)
    for name,command in pairs(commands.list()) do
        if users.has_permission(user, command.permission) then
            core.send("!" .. name .. " - " .. command.help)
        end
    end
end

local function cmd_ping(user, args)
    core.send_to_user(user.name, lang.default_commands.pong)
end

local function cmd_whoami(user, args)
    core.send_to_user(user.name, lang.default_commands.whoami:format(user.role))
end

local function cmd_role(user, args)
    if #args ~= 2 then core.send_to_user(user.name, "!role <user> <role>") end

    local target = users.get(args[1])
    target.role = args[2]
    users.persist(target)
    core.send_to_user(user.name, lang.default_commands.set_role:format(target.name, target.role))
    print(user.name .. " set " .. target.name .. "'s role to " .. target.role)
end

local function cmd_setmod(user, args)
    if #args ~= 1 then core.send_to_user(user.name, "!setmod <user>") end
    local target = args[1]
    core.send(".mod " .. target)
    core.send_to_user(user.name, lang.default_commands.set_mod(target))
    print(user.name .. " set " .. target .. " as a twitch mod")
end

local function cmd_stopbot(user, args)
    core.send(lang.default_commands.stop_bot)
    core.stop()
end

function plugin.init()
    commands.register("help", "displays the list of commands", cmd_help, "util.help")
    commands.register("ping", "pong", cmd_ping, "util.ping")
    commands.register("whoami", "display your role", cmd_whoami, "util.whoami")
    commands.register("role", "set a user's role", cmd_role, "util.set_role")
    commands.register("setmod", "set a user as a twitch mod", cmd_setmod, "util.set_mod")
    commands.register("stopbot", "stop xtlbot", cmd_stopbot, "util.stop")
end

return plugin