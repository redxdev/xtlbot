--[[
User Permissions Guide
----------------------

Each key of the "roles" table is the name of a user role (used in the !role command).
There are two roles that are required to exist: "user" and "admin". The user role
is given to all users unless you set their role with !role, while the superadmin
permission is given to the user who is specified in config.lua (under config.sudo).

Actual permissions are specified by adding a permissions key to a role. The permissions
key should be a list of permissions to give to that role.

If the role should inherit permissions from another role, then the "inherits" key should
be set to a list of the names of roles.

Some plugins may also allow you to define additional keys for each role, such as the
"throttle" and "command_throttle" keys which are used by the throttle plugin. Check
the plugin's documentation to see what options you can specify, and if those options
are inherited through the role hierarchy.
]]

local roles = {
    limited = {
        permissions = {
            "role.limited",
            "points.check"
        },
        throttle = 10, -- 1 message per 10 seconds
        command_throttle = 20
    },
    user = {
        permissions = {
            "role.user",
            "util.ping",
            "util.whoami",
            "custom_commands.use",
            "raffle.enter",
            "poll.vote",
            "points.check"
        },
        throttle = 1, -- 1 message per second
        command_throttle = 3
    },
    trusted = {
        inherits = {"user"},
        permissions = {
            "role.trusted",
            "filter.bypass",
            "custom_commands.list"
        },
        throttle = -1, -- no throttle
        command_throttle = -1
    },
    mod = {
        inherits = {"trusted"},
        permissions = {
            "role.mod",
            "filter.allow"
        },
        autosetmod = true, -- automatically set them as a moderator of the channel
        throttle = -1, -- no throttle
        command_throttle = -1
    },
    admin = {
        inherits = {"mod"},
        permissions = {
            "role.admin",
            "util.help",
            "util.set_role",
            "util.stop",
            "raffle.start",
            "raffle.end",
            "raffle.cancel",
            "poll.start",
            "poll.end",
            "custom_commands.add",
            "custom_commands.delete",
            "timed_messages.add",
            "timed_messages.delete",
            "timed_messages.list",
            "filter.block",
            "filter.unblock",
            "twitch.mod",
            "points.give"
        },
        autosetmod = true, -- automatically set them as a moderator of the channel
        throttle = -1, -- no throttle
        command_throttle = -1
    }
}

return roles