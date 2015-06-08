# eXtendable Twitch Lua Bot

xtlbot is a configurable twitch bot made with moderation capabilities in mind. It is written in Lua (5.1).
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

### Permissions

You can find the permissions configuration in "config/permissions.lua". There is some documentation on how to configure
roles and permissions within the file itself.

### Language strings

You can customize certain xtlbot chat messages by editing the files in "config/lang". Each plugin generally has its own
language file.

## Running

To run xtlbot, run the following in the installation directory:

    lua xtlbot.lua

If all goes well, you should have this printed somewhere in your console with no errors:

    Connecting to server irc.twitch.tv:6667
    Connection successful, logging in as <your bot name>

## Are we there yet?

xtlbot is not nearly production ready. It is in the early stages of development and should not be used.

## Plugins

xtlbot includes a simple to use plugin system. Plugin logic is placed in lua files in the "plugins" directory. Plugins
may also have files that go in the "config/lang" and "config/plugins" directory. To enable a plugin, add the name of it
to "config/plugins.lua".

If you want to see how to write a plugin, take a look at the default set of plugins provided in the "plugins" directory.

## Twitch

Sometimes I stream development of xtlbot. Check it out at http://www.twitch.tv/xtlbot