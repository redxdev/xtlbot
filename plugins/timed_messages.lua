-- This plugin provides timed messages for twitch chat
local require = require
local error = error
local concat = table.concat
local pairs = pairs
local print = print
local tonumber = tonumber

local sqlite3 = require("lsqlite3")
local socket = require("socket")

local core = require("src.core")
local commands = require("src.commands")

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

local function cmd_timed(user, args)
    if #args == 1 then
        local name = args[1]
        if messages[name] then
            local id = messages[name].id
            messages[name] = nil
            local stm = core.db():prepare("delete from timed_messages where id = ?")
            stm:bind(1, id)
            for _ in stm:urows() do end
            core.send_to_user(user.name, "Removed timed message " .. name)
        else
            core.sent_to_user(user.name, "unknown timed message " .. name)
        end
    elseif #args >= 3 then
        local name = args[1]
        if messages[name] then
            core.send_to_user(user.name, "That message already exists!")
            return
        end

        local time = tonumber(args[2])
        local message = concat(args, " ", 3)
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

        core.send_to_user(user.name, "Created timed message " .. name)

        print(user.name .. " created timed message " .. name .. " with time " .. time .. " and contents " .. message)
    else
        core.send_to_user(user.name, "!timed <name> <seconds> <message>")
    end
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

    commands.register("timed", "create a timed message", cmd_timed, "util.timed_message")
end

return plugin