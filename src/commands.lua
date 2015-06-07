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
local lang = require("config.lang")

local command_list = {}

local commands = {}

local function process_message(sender, origin, msg, pm)
    if #sender ~= 3 then return end -- make sure we are looking at a user

    if #msg > 0 and msg:sub(1, 1) == "!" then
        local arguments = explode(" ", msg)
        local name = arguments[1]:sub(2)
        if command_list[name] then
            local command = command_list[name]
            local user = users.get(sender[1])
            if not users.has_role(user, command.role) then
                core.send_to_user(user.name, lang.missing_role)
                return
            end

            print("Command \"" .. name .. "\" called by " .. sender[1])
            remove(arguments, 1)
            local status, err = pcall(command.callback, user, arguments)
            if not status then
                print("Error while calling command " .. name .. ": " .. err)
                core.send_to_user(sender[1], "There was a problem running that command.")
            end
        else
            core.send_to_user(sender[1], lang.unknown_command)
        end
    end
end

function commands.init(corelib)
    core = corelib
    core.hook_message(process_message)
end

function commands.register(name, help, callback, role)
    assert(type(name) == "string", "command name must be a string")
    assert(type(help) == "string", "command help must be a string")
    assert(type(callback) == "function", "command callback must be a function")
    assert(type(role) == "string", "command role must be a string")

    if command_list[name] then
        error("Command " .. name .. " already registered!")
    end

    command_list[name] = {
        name = name,
        help = help,
        callback = callback,
        role = role
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

return commands