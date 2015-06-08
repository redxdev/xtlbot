-- This plugin provides fun raffles for users
local require = require
local error = error
local print = print
local tonumber = tonumber
local insert = table.insert
local pairs = pairs
local random = math.random

local socket = require("socket")

local core = require("src.core")
local commands = require("src.commands")
local lang = require("src.lang")
local config = require("config.plugins.raffle")

local current_raffle

local plugin = {}

local function loop_hook()
    local currentTime = socket.gettime()

    if current_raffle then
        if current_raffle.next_announce < currentTime and config.announce_time > 0 then
            core.send(lang.raffle.announce)
            current_raffle.next_announce = currentTime + config.announce_time
        end

        if current_raffle.mode == "timed" then
            if current_raffle.end_time < currentTime then
                plugin.end_raffle()
            end
        end
    end
end

local function cmd_raffle(user, args)
    if current_raffle then
        core.send_to_user(user.name, lang.raffle.already_started)
        return
    end

    current_raffle = {
        entries = {},
        next_announce = socket.gettime() + config.announce_time
    }

    if #args == 0 then
        current_raffle.mode = "manual"

        core.send(lang.raffle.start)
    else
        local time = tonumber(args[1])
        if time < 1 then
            core.send_to_user(user.name, lang.raffle.min_time:format(1))
            return
        end

        current_raffle.mode = "timed"
        current_raffle.end_time = socket.gettime() + time

        core.send(lang.raffle.start_timed:format(time))
    end
end

local function cmd_enter(user, args)
    if not current_raffle then
        core.send_to_user(user.name, lang.raffle.not_running)
        return
    end

    for _,name in pairs(current_raffle.entries) do
        if name == user.name then
            core.send_to_user(user.name, lang.raffle.already_entered)
            return
        end
    end

    insert(current_raffle.entries, user.name)
    core.send_to_user(user.name, lang.raffle.entered)
end

local function cmd_endraffle(user, args)
    if not current_raffle then
        core.send_to_user(user.name, lang.raffle.not_running)
        return
    end

    plugin.end_raffle()
end

local function cmd_cancelraffle(user, args)
    if not current_raffle then
        core.send_to_user(user.name, lang.raffle.not_running)
        return
    end

    current_raffle = nil
    core.send(lang.raffle.canceled)
end

function plugin.init()
    core.hook_loop(loop_hook)

    commands.register("raffle", "start a raffle", cmd_raffle, "raffle.start")
    commands.register("endraffle", "end a raffle", cmd_endraffle, "raffle.end")
    commands.register("enter", "enter a raffle", cmd_enter, "raffle.enter")
    commands.register("cancelraffle", "cancel a raffle", cmd_cancelraffle, "raffle.cancel")
end

function plugin.end_raffle()
    local entries = current_raffle.entries
    current_raffle = nil

    if #entries == 0 then
        core.send(lang.raffle.no_entries)
        return
    end

    local idx = random(#entries)
    local winner = entries[idx]
    core.send(lang.raffle.winner:format(winner))
end

return plugin