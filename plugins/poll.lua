-- This plugin provides fun polls for users
local require = require
local assert = assert
local ipairs = ipairs
local pairs = pairs
local insert = table.insert
local tonumber = tonumber
local concat = table.concat
local sort = table.sort

local socket = require("socket")

local core = require("src.core")
local commands = require("src.commands")
local lang = require("src.lang")

local current_poll

local plugin = {}

local function poll_options_str()
    assert(current_poll)

    local result = ""
    for i,v in ipairs(current_poll.options) do
        if i ~= 1 then
            result = result .. ", "
        end

        result = result .. i .. ": " .. v
    end

    return result
end


local function loop_hook()
    local currentTime = socket.gettime()

    if current_poll then
        if current_poll.next_announce < currentTime then
            core.send(lang.poll.announce:format(poll_options_str()))
            current_poll.next_announce = currentTime + 20
        end
    end
end

local function cmd_poll(user, args)
    if current_poll then
        core.send_to_user(user.name, lang.poll.already_started)
    end

    if #args == 0 then
        core.send_to_user(user.name, "!poll <option1> | <option2> | ... | <optionN>")
        return
    end

    local options = {}
    local currentOption = ""
    for _,v in ipairs(args) do
        if v == "|" then
            if #currentOption == 0 then
                core.send_to_user(user.name, lang.poll.empty_option)
                return
            end
            insert(options, currentOption)
            currentOption = ""
        else
            if currentOption == "" then
                currentOption = v
            else
                currentOption = currentOption .. " " .. v
            end
        end
    end

    if #currentOption > 0 then insert(options, currentOption) end

    if #options < 2 then
        core.send_to_user(user.name, lang.poll.single_option)
    end

    current_poll = {
        results = {},
        options = options,
        next_announce = socket.gettime() + 20
    }

    core.send(lang.poll.start:format(poll_options_str()))
end

local function cmd_vote(user, args)
    if not current_poll then
        core.send_to_user(user.name, lang.poll.not_running)
    end

    if #args ~= 1 then
        core.send_to_user(user.name, "!vote <number>")
        return
    end

    if current_poll.results[user.name] then
        local option = tonumber(args[1])

        if option <= 0 or option > #(current_poll.options) then
            core.send_to_user(user.name, lang.poll.invalid_option)
            return
        end

        if option == current_poll.results[user.name] then
            core.send_to_user(user.name, lang.poll.repeat_option)
            return
        end

        current_poll.results[user.name] = option
        core.send_to_user(user.name, lang.poll.changed_vote:format(current_poll.options[option]))
    else
        local option = tonumber(args[1])

        if option < 0 or option > #(current_poll.options) then
            core.send_to_user(user.name, lang.poll.invalid_option)
            return
        end

        current_poll.results[user.name] = option
        core.send_to_user(user.name, lang.poll.voted:format(current_poll.options[option]))
    end
end

local function cmd_endpoll(user, args)
    if not current_poll then
        core.send_to_user(user.name, lang.poll.not_running)
    end

    local options = current_poll.options
    local results = current_poll.results
    current_poll = nil

    local counts = {}
    for k in ipairs(options) do
        counts[k] = 0
    end

    for _,v in pairs(results) do
        counts[v] = counts[v] + 1
    end

    results = {}
    for k,v in pairs(counts) do
        insert(results, {option = options[k], votes = v})
    end
    sort(results, function(a,b) return a.votes > b.votes end)

    local winstr = ""

    local winners = {}
    for _,v in ipairs(results) do
        insert(winners, v.option .. ": " .. v.votes)
    end

    local winstr = concat(winners, ", ")
    core.send(lang.poll.winner:format(winstr))
end

function plugin.init()
    core.hook_loop(loop_hook)

    commands.register("poll", "start a poll", cmd_poll, "poll.start")
    commands.register("vote", "vote in a poll", cmd_vote, "poll.vote")
    commands.register("endpoll", "end a poll", cmd_endpoll, "poll.end")
end

return plugin