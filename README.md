# eXtendable Twitch Lua Bot

xtlbot is a highly configurable twitch bot made with moderation capabilities in mind. It is written in Lua (for 5.1).
Currently, a single instance of xtlbot can only work with a single channel at a time.

## Installation

To make it easy to install dependencies, get [LuaRocks](https://luarocks.org/). Run the following commands:

    luarocks install irc-engine
    luarocks install lsqlite3
    luarocks install luasocket

You may have to build some dependencies yourself (especially on windows). Put xtlbot's files wherever you like, and you
can move onto configuration!

## Configuring

### Main Configuration

All configuration files are written in lua and are located in the "config" directory. The first thing you have to do to
get xtlbot working is copy "config/config.lua.dist" to "config/config.lua" and edit it. Replace the username, token,
and channel with the appropriate values for your bot. Set "sudo" to the name of the twitch user you want to have
superadmin

#### sudo

When you first setup xtlbot, you'll want to set sudo to either the bot's username or your username. Once you do, run the
bot and run "!role <username> superadmin" in the channel the bot is monitoring. You should then set the value of sudo
to "nil" (no quotes). If you do not do this, you will get a warning every time xtlbot starts up.

### Roles

The role hierarchy can be configured in "config/roles.lua". Generally, you want to leave this alone. Each key is a table
with a list of roles it inherits from.

### Language

You can customize certain xtlbot chat messages by editing "config/lang.lua".

## Running

To run xtlbot, run the following in the installation directory:

    lua xtlbot.lua

If all goes well, you should have this printed somewhere in your console with no errors:

    Connecting to server irc.twitch.tv:6667
    Connection successful, logging in as <your bot name>

## Are we there yet?

xtlbot is not nearly production ready. It is in the early stages of development and should not be used.

## Plugins

xtlbot includes a simple to use plugin system. Plugins are placed in the "plugins" directory. To enable a plugin, put
the name of the lua file in "config/plugins.lua". The default set of xtlbot commands (help, whoami, role, ping) is
implemented as the "default_commands" plugin if you want to see how it works.

## Twitch

Sometimes I stream development of xtlbot. Check it out at http://www.twitch.tv/xtlbot