-- poll plugin strings

local lang = {
    start = "A poll has been started with the options %s. Type \"!vote <number>\" to cast your vote!",
    alread_started = "This is already a poll going on!",
    empty_option = "You have an empty option in your poll!",
    single_option = "You only have one option in your poll!",
    not_running = "There is no poll going on right now!",
    invalid_option = "That's an invalid option to vote for.",
    repeat_option = "You already voted for that option.",
    changed_vote = "You have changed your vote to %s",
    voted = "You have voted for %s",
    winner = "The poll has been closed! [Results] %s",
    announce = "Type \"!vote <number>\" to vote on the poll: %s"
}

return lang