-- xtlbot configuration script

require("src.stringutils")
local info = require("src.info")

local function file_exists(name)
    local f=io.open(name,"r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

local function escape_format(str)
    return str:gsub("%%", "%%%%")
end

info.print_preamble()
print "Configuration Script"
print "--------------------"
print "Welcome to the xtlbot configuration script."
print "I'm going to check a few things before we start."
print "One moment please..."

print ""

local db_exists = false
if file_exists("database.sqlite3") then
    db_exists = true
end

if db_exists then
    print "It looks like there is already a database for xtlbot set up. Don't worry, this script won't ruin it."
end

local config_exists = false
if file_exists("config/config.lua") then
    config_exists = true
end

local skip_config = false
if config_exists then
    print "It looks like xtlbot is already configured. Do you want to skip the configuration step?"
    local answer
    repeat
        io.write ">> "
        io.flush()
        answer = io.read()
        answer = answer:lower()
    until answer == "y" or answer == "n" or answer == "yes" or answer == "no"
    if answer == "y" or answer == "yes" then
        skip_config = true
    end
    print ""
end

if not skip_config then
    print "First thing's first, we need to setup the main configuration."

    local username
    local token
    local channel

    local retry = true
    repeat
        print "What is the username of the bot?"
        io.write ">> "
        io.flush()
        username = io.read()

        print ""

        local oauth_ok = false
        repeat
            print "What is the oauth token for the bot? If you don't have a token, you can get one at http://www.twitchapps.com/tmi/"
            print "The token looks like this: oauth:zabcdef1234asdfghjklqwe4r56yui"
            io.write ">> "
            io.flush()
            token = io.read()
            if token:sub(1, 6) == "oauth:" and #token == 36 then
                oauth_ok = true
            else
                print ""
                print "That oauth token doesn't look right, let's try again."
                oauth_ok = false
            end
        until oauth_ok == true

        print ""

        local channel_ok = false
        repeat
            print "What channel should the bot watch? This should be the username of the channel (i.e. xtlbot for the xtlbot channel)"
            io.write ">> "
            io.flush()
            channel = io.read()

            if channel:sub(1,1) == "#" then
                print "Please omit the # at the beginning of the channel name."
                channel_ok = false
            else
                channel_ok = true
            end
        until channel_ok == true

        print ""

        print "Let's make sure everything is correct."
        print("  username: " .. username)
        print("  token: " .. token)
        print("  channel: " .. channel)
        print "Does that all look correct?"
        local answer
        repeat
            io.write ">> "
            io.flush()
            answer = io.read()
            answer = answer:lower()
        until answer == "y" or answer == "n" or answer == "yes" or answer == "no"
        if answer == "y" or answer == "yes" then
            retry = false
        end
    until not retry

    print ""

    print "Ok, give me a moment while I make your config file..."

    local config_dist = io.open("config/config.lua.dist", "r")
    if not config_dist then
        print "Uh oh! I couldn't read config/config.lua.dist. I suggest trying to download it from https://github.com/redxdev/xtlbot/blob/master/config/config.lua.dist and running this script again."
        return
    end

    local config = config_dist:read("*all")
    config_dist:close()

    config = config:gsub("%%USERNAME%%", username):gsub("%%TOKEN%%", token):gsub("%%CHANNEL%%", channel)

    local config_file = io.open("config/config.lua", "w+")
    if not config_file then
        print "Uh oh! I couldn't write config/config.lua. Make sure I have permission and nothing else is using the file!"
        return
    end

    config_file:write(config)
    config_file:flush()
    config_file:close()

    print "Done setting up your configuration file!"
end

print ""

print("Loading database...")
local sqlite3 = require("lsqlite3")
local db,c,e = sqlite3.open("database.sqlite3")
if not db then
    print("There was a problem accessing the database: " .. c .. " - " .. e)
    return
end

-- fake core module that provides access to the database to the users module
local fakecore = {
    db = function() return db end
}

local users = require("src.users")
users.init(fakecore)

local has_admin = false
for v in db:urows("select count(*) from users where role = \"admin\"") do
    if v > 0 then
        has_admin = true
    end
end

local skip_admin = false
if has_admin then
    print "It looks like there is already an admin user set up. Do you want to skip creating a new admin user?"
    local answer
    repeat
        io.write ">> "
        io.flush()
        answer = io.read()
        answer = answer:lower()
    until answer == "y" or answer == "n" or answer == "yes" or answer == "no"
    if answer == "y" or answer == "yes" then
        skip_admin = true
    end
end

print ""

if not skip_admin then
    print "Now it is time to setup an administrator. This user will be able to access all of xtlbot's functions."
    print "Enter the username for the administrator (you can add more via \"!role <user> admin\" later)"
    io.write(">> ")
    io.flush()
    local admin_name = io.read()

    print ""

    print "Creating user..."

    local user = users.get(admin_name)

    print("Setting " .. user.name .. "'s role to admin")
    user.role = "admin"
    users.persist(user)
end

print("Cleaning up...")
db:close()

print ""

local plugin_list = {}
local lfs = require("lfs")
for file in lfs.dir("./plugins") do
    local name = file:match("(.*)%.lua")
    if name then
        table.insert(plugin_list, name)
    end
end

if #plugin_list == 0 then
    print "You don't seem to have any plugins installed that we can configure!"
    return
end

local plugins_exists = false
if file_exists("config/plugins.lua") then
    plugins_exists = true
end

local skip_plugins = false
if plugins_exists then
    print "It looks like you already have plugins enabled. Do you want to skip the plugins step?"
    local answer
    repeat
        io.write ">> "
        io.flush()
        answer = io.read()
        answer = answer:lower()
    until answer == "y" or answer == "n" or answer == "yes" or answer == "no"
    if answer == "y" or answer == "yes" then
        skip_plugins = true
    end
    print ""
end

if not skip_plugins then
    local plugins_done = false
    local plugins
    repeat
        print "Alright, now you get to choose which plugins to enable. Here's the list of plugins you currently have installed:"
        for k,v in ipairs(plugin_list) do
            print("  " .. k .. ": " .. v)
        end

        print "Select which plugins you want enabled by typing out a list of their numbers, separated by spaces."

        if #plugin_list >= 2 then
            print("For example, if you wanted " .. plugin_list[1] .. " and " .. plugin_list[2] .. " you would write \"1 2\"")
        end

        io.write(">> ")
        io.flush()
        local plugin_str = io.read()

        plugins = string.explode(" ", plugin_str)
        local plugins_ok = true
        for i,v in ipairs(plugins) do
            local sel = tonumber(v)
            if not sel or sel < 1 or sel > #plugin_list then
                plugins_ok = false
                break
            end
            plugins[i] = '\t"' .. plugin_list[sel] .. '"'
        end

        if plugins_ok then
            plugins_done = true
        else
            print "That was an invalid set of plugins!"
        end
    until plugins_done

    print "Alright, I'm going to write your new \"config/plugins.lua\". Give me a moment..."
    local file_str = [[
    -- List all plugins you want to enable here.

    local plugins = {
    ]] .. table.concat(plugins, ",\n") .. [[

    }

    return plugins]]
    local output = io.open("config/plugins.lua", "w+")
    if not output then
        print "There was a problem opening \"config/plugins.lua\" for writing!"
        return
    end

    output:write(file_str)
    output:flush()
    output:close()
end

print ""

print "All done! xtlbot should be ready to go. You can launch xtlbot by running \"lua xtlbot.lua\" or you can run this configuration again."
print "If you want to change what plugins are enabled or permission settings, check out the config directory. Otherwise, have fun!"
-- done