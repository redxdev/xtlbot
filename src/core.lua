-- xtlbot core
local require = require
local print = print
local error = error
local assert = assert
local insert = table.insert
local ipairs = ipairs
local type = type

local info = require("src.info")
local irce = require("irce")
local socket = require("socket")
local sqlite3 = require("lsqlite3")

local config = require("config.config")
local lang = require("config.lang")
local plugins = require("config.plugins")
local users = require("src.users")
local commands = require("src.commands")

local core = {}

local client
local irc
local running = false
local db

local msg_hooks = {}

function core.init()
    if running then
        error("Cannot re-initialize xtlbot when already running")
    end

    info.print_preamble()

    print("Loading database...")
    local d,c,e = sqlite3.open("database.sqlite3")
    if not d then
        error(c .. ": " .. e)
    end
    db = d

    irc = irce.new()
    assert(irc:load_module(require("irce.modules.base")))
    assert(irc:load_module(require("irce.modules.message")))
    assert(irc:load_module(require("irce.modules.channel")))
    assert(irc:load_module(require("src.twitch_irc")))

    running = true
    client = socket.tcp()
    client:settimeout(1)

    -- setup callbacks
    irc:set_send_func(function(message)
        return client:send(message)
    end)

    if config.debug_protocol then
        irc:set_callback("RAW", function(send, message)
            print(("%s %s"):format(send and ">>>" or "<<<", message))
        end)
    end

    irc:set_callback("001", function(...)
        assert(irc:JOIN(config.channel))
    end)

    irc:set_callback("PRIVMSG", function(sender, origin, msg, pm)
        if config.show_messages then
            print(sender[1] .. ": " .. msg)
        end

        for _,hook in ipairs(msg_hooks) do
            hook(sender, origin, msg, pm)
        end
    end)

    -- connect and log in
    print("Connecting to server " .. config.server .. ":" .. config.port)
    assert(client:connect(config.server, config.port))

    print("Connection successful, logging in as " .. config.username)
    assert(irc:PASS(config.token))
    assert(irc:NICK(config.username))

    users.init(core)
    commands.init(core)

    -- plugins
    for _,name in ipairs(plugins) do
        print("Loading plugin " .. name)
        local plugin = require("plugins." .. name)
        plugin.init(core)
    end

    while running do
        irc:process(client:receive())
    end

    print "Shutting down xtlbot"
    irc:PART()
    client:close()
    db:close()
end

function core.stop()
    print("Stopping xtlbot")
end

function core.send(message)
    irc:send("PRIVMSG", config.channel, message)
end

function core.send_to_user(user, message)
    core.send(lang.to_user:format(user, message))
end

function core.db()
    return db
end

function core.client()
    return irc
end

function core.socket()
    return client
end

function core.hook_message(f)
    assert(type(f) == "function", "message hook must be a function")
    insert(msg_hooks, f)
end

return core