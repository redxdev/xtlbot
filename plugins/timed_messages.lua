-- This plugin provides timed messages for twitch chat
local require = require
local error = error
local concat = table.concat
local pairs = pairs
local print = print
local tonumber = tonumber
local insert = table.insert

local sqlite3 = require("lsqlite3")
local socket = require("socket")

local core = require("src.core")
local commands = require("src.commands")
local lang = require("src.lang")

local messages = {}

local plugin = {}

local function message_loop()
    local currentTime = socket.gettime()
    for _,msg in pairs(messages) do
        if msg.last_time_sent + msg.time < currentTime then
            core.send(msg.message)
            msg.last_time_sent = currentTime
        end
    end
end

local function cmd_addmessage(user, args)
    if #args < 3 then
        core.send_to_user(user.name, "!addmsg <name> <seconds> <message>")
        return
    end

    local name = args[1]
    if messages[name] then
        core.send_to_user(user.name, lang.timed_messages.already_exists)
        return
    end

    local time = tonumber(args[2])
    local message = concat(args, " ", 3)

    if time == nil or time < 1 then
        core.send_to_user(user.name, lang.timed_messages.invalid_time)
        return
    end

    if message == nil or #message == 0 then
        core.send_to_user(user.name, lang.timed_messages.invalid_message)
        return
    end

    local stm = core.db():prepare("insert into timed_messages (name, message, time) values (?, ?, ?)")
    stm:bind(1, name)
    stm:bind(2, message)
    stm:bind(3, time)
    for _ in stm:urows() do end

    local msg = {
        message = message,
        name = name,
        time = time,
        last_time_sent = socket.gettime(),
    }

    -- meh
    stm = core.db():prepare("select id from timed_messages where name = ?")
    stm:bind(1, name)
    for id in stm:urows() do
        msg.id = id
    end

    messages[name] = msg

    core.send_to_user(user.name, lang.timed_messages.created:format(msg.name))

    print(user.name .. " created timed message " .. name .. " with time " .. time .. " and contents " .. message)
end

local function cmd_delmessage(user, args)
    if #args ~= 1 then
        core.send_to_user(user.name, "!delmsg <name>")
        return
    end

    local name = args[1]
    if messages[name] then
        local id = messages[name].id
        messages[name] = nil
        local stm = core.db():prepare("delete from timed_messages where id = ?")
        stm:bind(1, id)
        for _ in stm:urows() do end
        core.send_to_user(user.name, lang.timed_messages.deleted:format(name))
    else
        core.send_to_user(user.name, lang.timed_messages.unknown:format(name))
    end
end

local function cmd_listmsg(user, args)
    local names = {}
    for k,v in pairs(messages) do
        insert(names, k)
    end

    core.send_to_user(user.name, lang.timed_messages.list:format(concat(names, ", ")))
end

function plugin.init()
    local sql = [[
        create table if not exists timed_messages
        (
            id integer primary key autoincrement,
            name varchar(32) unique,
            message text,
            time integer
        );
    ]]
    local result = core.db():exec(sql)
    if result ~= sqlite3.OK then
        error("Unable to initialize database for timed_messages (error code " .. result .. ")")
    end

    local stagger = 0
    for v in core.db():nrows("select * from timed_messages") do
        local msg = {
            id = v.id,
            name = v.name,
            message = v.message,
            time = v.time,
            last_time_sent = socket.gettime() + stagger * 13
        }

        stagger = stagger + 1

        messages[msg.name] = msg
    end

    core.hook_loop(message_loop)

    commands.register("addmsg", "create a timed message", cmd_addmessage, "timed_messages.add")
    commands.register("delmsg", "delete a timed message", cmd_delmessage, "timed_messages.delete")
    commands.register("listmsg", "list timed messages", cmd_listmsg, "timed_messages.list")
end

return plugin