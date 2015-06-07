local roles = {
    locked = {
        permissions = {
            "role.locked"
        }
    },
    user = {
        permissions = {
            "role.user",
            "util.help",
            "util.ping",
            "util.whoami",
            "util.custom_command.use"
        }
    },
    mod = {
        inherits = {"user"},
        permissions = {
            "role.mod"
        }
    },
    admin = {
        inherits = {"mod"},
        permissions = {
            "role.admin",
            "util.custom_command",
            "util.timed_message"
        }
    },
    superadmin = {
        inherits = {"admin"},
        permissions = {
            "role.superadmin",
            "util.set_role",
            "util.set_mod"
        }
    }
}

return roles