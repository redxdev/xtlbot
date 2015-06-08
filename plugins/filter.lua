-- Plugin for filtering chat
local require = require
local print = print
local error = error
local insert = table.insert
local remove = table.remove
local ipairs = ipairs

local sqlite3 = require("lsqlite3")

local core = require("src.core")
local users = require("src.users")
local lang = require("src.lang")
local commands = require("src.commands")

local blocked_words = {}

local plugin = {}

local function premessage_hook(sender, origin, msg, pm)
    local user = users.get(sender[1])
    if users.has_permission(user, "filter.bypass") then
        return true
    end

    for _,v in ipairs(blocked_words) do
        if msg:find(v.word) ~= nil then
            core.send_to_user(user.name, lang.filter.blocked)
            core.timeout(user.name, 2)
            print("Blocked " .. user.name .. " from saying " .. v.word)
            return false
        end
    end

    return true
end

local function cmd_block(user, args)
    if #args ~= 1 then
        core.send_to_user(user.name, "!block <word>")
        return
    end

    for _,v in ipairs(blocked_words) do
        if v.word == args[1] then
            core.send_to_user(user.name, lang.filter.already_blocked)
            core.timeout(user.name, 1)
            return
        end
    end

    local stm = core.db():prepare("insert into blocked_words (word) values (?)")
    stm:bind(1, args[1])
    for _ in stm:urows() do end

    local data = {
        word = args[1]
    }
    -- meh
    stm = core.db():prepare("select id from blocked_words where word = ?")
    stm:bind(1, args[1])
    for id in stm:urows() do
        data.id = id
    end

    insert(blocked_words, data)
    core.send_to_user(user.name, lang.filter.added_word)
    core.timeout(user.name, 1)
    print(user.name .. " blocked word " .. data.word)
end

local function cmd_unblock(user, args)
    if #args ~= 1 then
        core.send_to_user(user.name, "!unblock <word>")
        return
    end

    local found
    for i,v in ipairs(blocked_words) do
        if v.word == args[1] then
            remove(blocked_words, i)
            found = v
            break
        end
    end

    if not found then
        core.send_to_user(user.name, lang.filter.unknown_word)
        return
    end

    local stm = core.db():prepare("delete from blocked_words where id = ?")
    stm:bind(1, found.id)
    for _ in stm:urows() do end

    core.send_to_user(user.name, lang.filter.removed_word)
    print(user.name .. " unblocked word " .. found.word)
end

function plugin.init()
    local sql = [[
        create table if not exists blocked_words
        (
            id integer primary key autoincrement,
            word text unique
        );
    ]]
    local result = core.db():exec(sql)
    if result ~= sqlite3.OK then
        error("Unable to initialize database for filter (error code " .. result .. ")")
    end

    for v in core.db():nrows("select * from blocked_words") do
        insert(blocked_words, {
            word = v.word,
            id = v.id
        })
    end

    core.hook_premessage(premessage_hook)

    commands.register("block", "block a word from being said", cmd_block, "filter.block")
    commands.register("unblock", "unblock a word from being said", cmd_unblock, "filter.unblock")
end

return plugin