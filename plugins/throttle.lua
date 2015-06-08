-- xtlbot message throttling
local require = require
local print = print
local error = error
local assert = assert
local insert = table.insert
local pairs = pairs
local ipairs = ipairs
local type = type

local socket = require("socket")

local core = require("src.core")
local users = require("src.users")
local config = require("config.config")
local lang = require("config.lang")

local recent_messages = {}
local recent_commands = {}

local plugin = {}

function users.get_throttle(role)
    if type(role) == "string" then
        role = users.get_role(role)
    end

    assert(type(role) == "table")

    if role.throttle then return role.throttle end

    return -1
end

function users.get_command_throttle(role)
    if type(role) == "string" then
        role = users.get_role(role)
    end

    assert(type(role) == "table")

    if role.command_throttle then return role.command_throttle end

    return -1
end

local function loop_hook()
    local currentTime = socket.gettime()

    for name,times in pairs(recent_messages) do
        local user = users.get(name)
        local tv = users.get_throttle(user.role)

        local active = {}
        for _,time in ipairs(times) do
            if currentTime - tv < time then
                insert(active, time)
            end
        end

        recent_messages[name] = active
    end

    for name,times in pairs(recent_commands) do
        local user = users.get(name)
        local tv = users.get_command_throttle(user.role)

        local active = {}
        for _,time in ipairs(times) do
            if currentTime - tv < time then
                insert(active, time)
            end
        end

        recent_commands[name] = active
    end
end

local function premessage_hook(sender, origin, msg, pm)
    local user = users.get(sender[1])
    return plugin.check_message(user, msg)
end

function plugin.init()
    core.hook_premessage(premessage_hook)
    core.hook_loop(loop_hook)
end

function plugin.check_message(user, msg)
    if users.get_throttle(user.role) < 0 then return true end

    local currentTime = socket.gettime()

    if #msg > 0 then
        if msg:sub(1,1) == "!" then
            local recent = recent_commands[user.name]
            if not recent then
                recent = {}
                recent_commands[user.name] = recent
            end

            insert(recent, currentTime)

            if #recent >= 2 then
                local tv = users.get_command_throttle(user.role)
                core.send_to_user(user.name, lang.throttle_command)
                core.timeout(user.name, tv)
                print("Command throttled " .. user.name)
            end
        else
            local recent = recent_messages[user.name]
            if not recent then
                recent = {}
                recent_messages[user.name] = recent
            end

            insert(recent, currentTime)

            if #recent >= 2 then
                local tv = users.get_throttle(user.role)
                core.send_to_user(user.name, lang.throttle:format(tv))
                core.timeout(user.name, tv)
                print("Throttled " .. user.name)
            end
        end
    end
end

return plugin