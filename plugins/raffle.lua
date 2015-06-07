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
local lang = require("config.lang")

local current_raffle

local plugin = {}

local function loop_hook()
    if current_raffle then
        local currentTime = socket.gettime()
        if current_raffle.end_time < currentTime then
            plugin.end_raffle()
        end
    end
end

local function cmd_raffle(user, args)
    if #args == 1 then
        current_raffle = {
            entries = {}
        }

        if args[1] == "manual" then
            current_raffle.mode = "manual"

            core.send(lang.raffle_start)
        else
            local time = tonumber(args[1])
            if time < 1 then
                core.send_to_user(user.name, "Raffle time must be at least 1 second")
                return
            end

            current_raffle.mode = "timed"
            current_raffle.end_time = socket.gettime() + time

            core.send(lang.raffle_start_timed:format(time))
        end
    else
        core.send_to_user(user.name, "!raffle <number/manual>")
    end
end

local function cmd_enter(user, args)
    if not current_raffle then
        core.send_to_user(user.name, lang.raffle_not_running)
        return
    end

    for _,name in pairs(current_raffle.entries) do
        if name == user.name then
            core.send_to_user(user.name, lang.raffle_already_entered)
            return
        end
    end

    insert(current_raffle.entries, user.name)
    core.send_to_user(user.name, lang.raffle_entered)
end

local function cmd_endraffle(user, args)
    if not current_raffle then
        core.send_to_user(user.name, lang.raffle_not_running)
        return
    end

    plugin.end_raffle()
end

function plugin.init()
    core.hook_loop(loop_hook)

    commands.register("raffle", "start a raffle", cmd_raffle, "raffle.start")
    commands.register("endraffle", "end a raffle", cmd_endraffle, "raffle.end")
    commands.register("enter", "enter a raffle", cmd_enter, "raffle.enter")
end

function plugin.end_raffle()
    local entries = current_raffle.entries
    current_raffle = nil

    if #entries == 0 then
        core.send("No one entered the raffle :(")
        return
    end

    local idx = random(#entries)
    local winner = entries[idx]
    core.send("The winner of the raffle is " .. winner .. "!")
end

return plugin