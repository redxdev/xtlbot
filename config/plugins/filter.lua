--[[
filter plugin config
--------------------

This config is a bit more complex than most, as we want to let you setup the filter to
work however you want. You'll notice that we actually use some lua code aside from just
defining tables in this file.

Ignore the require lines, as those just give us some useful functions to work with (such
as string.has_url and access to the lang config files).

The complex part of the config is in the "rules" key. This should be a list of tables,
where each table has a "message" and a "match" key (the message key is optional). The match
key can be a pattern (see http://lua-users.org/wiki/PatternsTutorial) or it can be a function
that returns true if the message should be blocked and false if the message is ok.

The "message" key is what the bot sends to the user if their message was blocked.

A warning about using lua's patterns: They aren't the same regular expressions you're used to.
They aren't as powerful. I suggest installing either LPeg or lrexlib-pcre if you want more than
Lua's inbuilt pattern matching.
]]

require("src.stringutils")
local lang = require("src.lang")

local config = {
    rules = {
        -- URL Rule
        {
            message = lang.filter.url,
            match = string.has_url
        },

        -- Caps rule
        -- The default is to fail any strings with > 4 characters that have > 80% caps in them.
        -- Change the "4" and "0.8" in the match line to change these values.
        {
            message = lang.filter.caps,
            match = function(str) return #str > 4 and string.caps_percent(str) > 0.8 end
        },

        -- Symbols rule
        -- The default is to fail any strings with > 4 characters that have > 80% caps in them.
        -- Change the "4" and "0.8" in the match line to change these values.
        {
            message = lang.filter.symbols,
            match = function(str) return #str > 4 and string.symbols_percent(str) > 0.8 end
        }
    }
}

return config