-- utility functions for twitch's irc stuff, for use with irc-engine

return {
    senders = {
        PASS = function(self, password)
            return "PASS " .. password
        end
    }
}