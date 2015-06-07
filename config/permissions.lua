local roles = {
    locked = {
        permissions = {
            "role.locked"
        },
        throttle = 10 -- 1 message per 10 seconds
    },
    user = {
        permissions = {
            "role.user",
            "util.help",
            "util.ping",
            "util.whoami",
            "util.custom_command.use",
            "raffle.enter"
        },
        throttle = 1 -- 1 message per second
    },
    mod = {
        inherits = {"user"},
        permissions = {
            "role.mod"
        },
        throttle = -1 -- no throttle
    },
    admin = {
        inherits = {"mod"},
        permissions = {
            "role.admin",
            "util.custom_command",
            "util.timed_message",
            "raffle.start",
            "raffle.end"
        },
        throttle = -1 -- no throttle
    },
    superadmin = {
        inherits = {"admin"},
        permissions = {
            "role.superadmin",
            "util.set_role",
            "util.set_mod"
        },
        throttle = -1 -- no throtle
    }
}

return roles