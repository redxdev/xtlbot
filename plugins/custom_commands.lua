-- This plugin provides custom responses to commands
local require = require
local error = error
local concat = table.concat
local print = print
local pairs = pairs
local insert = table.insert

local sqlite3 = require("lsqlite3")

local core = require("src.core")
local commands = require("src.commands")
local lang = require("src.lang")

local messages = {}

local plugin = {}

local function send_message(name)
    core.send(messages[name].message)
end

local function cmd_addcom(user, args)
    if #args >= 2 then
        local name = args[1]
        if messages[name] then
            core.send_to_user(user.name, lang.custom_commands.exists:format(name))
            return
        end

        local message = concat(args, " ", 2)
        local stm = core.db():prepare("insert into custom_messages (command, description, message) values (?, ?, ?)")
        stm:bind(1, name)
        stm:bind(2, "custom command")
        stm:bind(3, message)
        for _ in stm:urows() do end

        local msg = {
            message = message,
            description = "custom command",
            command = name,
            func = function() send_message(name) end
        }

        commands.register(msg.command, msg.description, msg.func, "custom_commands.use")

        -- meh
        stm = core.db():prepare("select id from custom_messages where command = ?")
        stm:bind(1, name)
        for id in stm:urows() do
            msg.id = id
        end

        messages[msg.command] = msg

        core.send_to_user(user.name, lang.custom_commands.created:format(name))
    else
        core.send_to_user(user.name, "!addcom <name> <response>")
    end
end

local function cmd_delcom(user, args)
    if #args == 1 then
        local name = args[1]
        if messages[name] then
            commands.remove(name)
            local id = messages[name].id
            messages[name] = nil
            local stm = core.db():prepare("delete from custom_messages where id = ?")
            stm:bind(1, id)
            for _ in stm:urows() do end
            core.send_to_user(user.name, lang.custom_commands.deleted:format(name))
        else
            core.send_to_user(user.name, lang.global.unknown_command:format(name))
        end
    else
        core.send_to_user(user.name, "!delcom <name>")
    end
end

local function cmd_listcom(user, args)
    local names = {}
    for k,v in pairs(messages) do
        insert(names, "!" .. k)
    end

    core.send_to_user(user.name, lang.custom_commands.list:format(concat(names, ", ")))
end

function plugin.init()
    local sql = [[
        create table if not exists custom_messages
        (
            id integer primary key autoincrement,
            command varchar(32) unique,
            description text,
            message text
        );
    ]]
    local result = core.db():exec(sql)
    if result ~= sqlite3.OK then
        error("Unable to initialize database for custom_messages (error code " .. result .. ")")
    end

    for v in core.db():nrows("select * from custom_messages") do
        local name = v.command
        local msg = {
            id = v.id,
            message = v.message,
            description = v.description,
            command = name,
            func = function() send_message(name) end
        }
        commands.register(name, v.description, msg.func, "custom_commands.use")
        messages[name] = msg
    end

    commands.register("addcom", "create a custom command", cmd_addcom, "custom_commands.add")
    commands.register("delcom", "delete a custom command", cmd_delcom, "custom_commands.delete")
    commands.register("listcom", "list custom commands", cmd_listcom, "custom_commands.list")
end

return plugin