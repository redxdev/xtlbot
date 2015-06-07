local print = print

local info = {}

function info.version()
    return "1.0.0"
end

function info.print_preamble()
    print("xtlbot version " .. info.version())
    print("Copyright (c) 2015 Sam Bloomberg")
    print("This is released as free software under the MIT license.")
end

return info