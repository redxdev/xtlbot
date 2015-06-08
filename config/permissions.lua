local roles = {
    locked = {
        permissions = {
            "role.locked"
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
            "raffle.enter"
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
            "util.custom_command.add",
            "util.custom_command.delete",
            "util.timed_message",
            "raffle.start",
            "raffle.end"
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
            "util.set_mod"
        },
        throttle = -1, -- no throttle
        command_throttle = -1
    }
}

return roles