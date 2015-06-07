return {
    senders = {
        PASS = function(self, password)
            return "PASS " .. password
        end
    }
}