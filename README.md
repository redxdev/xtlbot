# eXtendable Twitch Lua Bot

xtlbot is a configurable twitch bot made with moderation capabilities in mind. It is written in Lua (5.1).
Currently, a single instance of xtlbot can only work with a single channel at a time.

## Installation

To make it easy to install dependencies, get [LuaRocks](https://luarocks.org/). Run the following commands:

    luarocks install irc-engine
    luarocks install lsqlite3
    luarocks install luasocket
    luarocks install luafilesystem

You may have to build some dependencies yourself (especially on windows). Put xtlbot's files wherever you like, and you
can move onto configuration!

## Configuring

xtlbot now comes with a nice little configuration script! After installing dependencies, you can run the configuration
from the xtlbot installation directory script like so:

    lua configuration.lua

You will need the oauth token for your bot, which can be found [here](http://www.twitchapps.com/tmi/).

This script will set up a single admin user for you as well.

If the configuration script fails for some reason, you can just run it again. If you can't seem to get it to work, you
can manually configure the bot by copying "config/config.lua.dist" to "config/config.lua" and editing it. You can use
the "sudo" configuration option to temporarily mark a user as an admin so that you can use the !role command.

## Running

To run xtlbot, run the following in the installation directory:

    lua xtlbot.lua

If all goes well, you should have this printed somewhere in your console with no errors:

    Connecting to server irc.twitch.tv:6667
    Connection successful, logging in as <your bot name>

## Configuration Files

All configuration files are located in the "config" directory.

### Main Configuration

The main configuration file is "config/config.lua". If you haven't run the configuration script yet, it won't exist. You
can copy "config/config.lua.dist" to "config/config.lua" if you don't want to run the configuration script.

### Permissions

You can find the permissions configuration in "config/permissions.lua". There is some documentation on how to configure
roles and permissions within the file itself.

### Language strings

You can customize certain xtlbot chat messages by editing the files in "config/lang". Each plugin generally has its own
language file.

## Are we there yet?

xtlbot is not nearly production ready. It is in the early stages of development and should not be used.

## Plugins

xtlbot includes a simple to use plugin system. Plugin logic is placed in lua files in the "plugins" directory. Plugins
may also have files that go in the "config/lang" and "config/plugins" directory. To enable a plugin, add the name of it
to "config/plugins.lua".

If you want to see how to write a plugin, take a look at the default set of plugins provided in the "plugins" directory.

## Twitch

Sometimes I stream development of xtlbot. Check it out at http://www.twitch.tv/xtlbot