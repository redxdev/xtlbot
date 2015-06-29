local require = require
local print = print
local error = error
local assert = assert
local insert = table.insert
local remove = table.remove
local type = type
local pcall = pcall

require "src.stringutils"

local explode = string.explode

local core
local users = require("src.users")
local lang = require("src.lang")
local config = require("config.config")

local command_list = {}

local commands = {}

local function process_message(sender, origin, msg, pm)
    if #sender ~= 3 then return end -- make sure we are looking at a user

    if #msg > 0 and msg:sub(1, 1) == "!" then
        local arguments = explode(" ", msg)
        local name = arguments[1]:sub(2)
        local user = users.get(sender[1])
        remove(arguments, 1)

        local status, msg = commands.call(user, name, arguments)
        if not status and msg ~= nil then
            core.send_to_user(user.name, msg)
        end
    end
end

function commands.init(corelib)
    core = corelib
    core.hook_message(process_message)
end

function commands.register(name, help, callback, permission)
    assert(type(name) == "string", "command name must be a string")
    assert(type(help) == "string", "command help must be a string")
    assert(type(callback) == "function", "command callback must be a function")
    assert(type(permission) == "string", "command role must be a string")

    if command_list[name] then
        error("Command " .. name .. " already registered!")
    end

    command_list[name] = {
        name = name,
        help = help,
        callback = callback,
        permission = permission
    }
end

function commands.remove(name)
    assert(type(name) == "string", "command name must be a string")
    if not command_list[name] then
        error("Command " .. name .. " not registered")
    end

    command_list[name] = nil
end

function commands.list()
    return command_list
end

function commands.call(user, name, arguments)
    assert(type(user) == "table", "user must be a table")
    assert(type(name) == "string", "name must be a string")
    assert(type(arguments) == "table", "arguments must be a table")

    if command_list[name] then
        local command = command_list[name]
        if not users.has_permission(user, command.permission) then
            return false, lang.global.missing_permission
        end

        print("Command \"" .. name .. "\" called by " .. user.name)
        local status, err = pcall(command.callback, user, arguments)
        if not status then
            print(err)
            return false, lang.global.command_error
        end

        return true
    elseif config.unknown_command then
        return false, lang.global.unknown_command:format(name)
    else
        return false
    end
end

return commands