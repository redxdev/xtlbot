-- Plugin for filtering chat
local require = require
local print = print
local error = error
local insert = table.insert
local remove = table.remove
local ipairs = ipairs
local type = type

local sqlite3 = require("lsqlite3")

local core = require("src.core")
local users = require("src.users")
local lang = require("src.lang")
local commands = require("src.commands")
local config = require("config.plugins.filter")

local blocked_words = {}
local temporary_bypass = {}

local plugin = {}

local function premessage_hook(sender, origin, msg, pm)
    local user = users.get(sender[1])
    if users.has_permission(user, "filter.bypass") then
        return true
    end

    local bypass = false
    if temporary_bypass[user.name:lower()] then
        bypass = true
    end

    for _,v in ipairs(blocked_words) do
        if msg:find(v.word) ~= nil then
            if bypass then
                temporary_bypass[user.name:lower()] = nil
                return true
            end

            core.send_to_user(user.name, lang.filter.word_blocked)
            core.timeout(user.name, 2)
            print("Blocked " .. user.name .. " from saying " .. v.word)
            return false
        end
    end

    for k,v in ipairs(config.rules) do
        if v.match then
            local matchtype = type(v.match)
            local message = v.message or lang.filter.generic_block
            if matchtype == "function" then
                if v.match(msg) then
                    if bypass then
                        temporary_bypass[user.name:lower()] = nil
                        return true
                    end

                    core.send_to_user(user.name, message)
                    core.timeout(user.name, 2)
                    print("Rule #" .. k .. " blocked " .. user.name .. " from saying " .. msg)
                    return false
                end
            elseif matchtype == "string" then
                if msg:find(v.match) then
                    if bypass then
                        temporary_bypass[user.name:lower()] = nil
                        return true
                    end

                    core.send_to_user(user.name, message)
                    core.timeout(user.name, 2)
                    print("Rule #" .. k .. " blocked " .. user.name " from saying " .. msg)
                    return false
                end
            end
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
            core.send_to_user(user.name, lang.filter.word_already_blocked)
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

local function cmd_allow(user, args)
    if #args ~= 1 then
        core.send_to_user(user.name, "!allow <user>")
        return
    end

    temporary_bypass[args[1]:lower()] = true
    core.send(lang.filter.temporary_bypass:format(args[1]))
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
    commands.register("allow", "allow a user to bypass the filter once", cmd_allow, "filter.allow")
end

return plugin