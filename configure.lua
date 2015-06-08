-- xtlbot configuration script

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

if config_exists then
    print "It looks like xtlbot is already configured. Are you sure you want to overwrite the configuration files?"
    local answer
    repeat
        io.write ">> "
        io.flush()
        answer = io.read()
        answer = answer:lower()
    until answer == "y" or answer == "n" or answer == "yes" or answer == "no"
    if answer == "n" or answer == "no" then
        print "Exiting!"
        return
    end
    print ""
end

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

    print "What channel should the bot watch? This should be the username of the channel (i.e. xtlbot for the xtlbot channel)"
    io.write ">> "
    io.flush()
    channel = io.read()

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

print ""

print "Now it is time to setup an administrator. This user will be able to access all of xtlbot's functions."
print "Enter the username for the administrator (you can add more via \"!role <user> admin\" later)"
io.write(">> ")
io.flush()
local admin_name = io.read()

print ""

print("Loading database...")
local sqlite3 = require("lsqlite3")
local db,c,e = sqlite3.open("database.sqlite3")
if not db then
    print("There was a problem accessing the database: " .. c .. " - " .. e)
    return
end

print "Creating user..."

-- fake core module that provides access to the database to the users module
local fakecore = {
    db = function() return db end
}

local users = require("src.users")
users.init(fakecore)

local user = users.get(admin_name)

print("Setting " .. user.name .. "'s role to admin")
user.role = "admin"
users.persist(user)

print("Cleaning up...")
db:close()

print ""

print "All done! xtlbot should be ready to go. You can launch xtlbot by running \"lua xtlbot.lua\" or you can run this configuration again."
print "If you want to change what plugins are enabled or permission settings, check out the config directory. Otherwise, have fun!"
-- done