--[[
User Permissions Guide
----------------------

Each key of the "roles" table is the name of a user role (used in the !role command).
There are two roles that are required to exist: "user" and "superadmin". The user role
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
            "role.limietd"
        },
        throttle = 10, -- 1 message per 10 seconds
        command_throttle = 20
    },
    user = {
        permissions = {
            "role.user",
            "util.ping",
            "util.whoami",
            "util.custom_command.use",
            "raffle.enter",
            "poll.vote"
        },
        throttle = 1, -- 1 message per second
        command_throttle = 3
    },
    mod = {
        inherits = {"user"},
        permissions = {
            "role.mod"
        },
        throttle = -1, -- no throttle
        command_throttle = -1
    },
    admin = {
        inherits = {"mod"},
        permissions = {
            "role.admin",
            "filter.bypass",
            "filter.block",
            "filter.unblock",
            "util.custom_command.add",
            "util.custom_command.delete",
            "util.timed_message.add",
            "util.timed_message.delete",
            "raffle.start",
            "raffle.end",
            "raffle.cancel",
            "poll.start",
            "poll.end"
        },
        throttle = -1, -- no throttle
        command_throttle = -1
    },
    superadmin = {
        inherits = {"admin"},
        permissions = {
            "role.superadmin",
            "util.help",
            "util.set_role",
            "util.set_mod",
            "util.stop"
        },
        throttle = -1, -- no throttle
        command_throttle = -1
    }
}

return roles