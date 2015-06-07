local require = require
local print = print
local error = error
local assert = assert
local type = type
local setmetatable = setmetatable
local ipairs = ipairs

local sqlite3 = require("lsqlite3")

local core
local config = require("config.config")
local roles = require("config.permissions")

local user_cache = {}
setmetatable(user_cache, {__mode = 'v'}) -- weak table

local users = {}

function users.init(corelib)
    print "Initializing user manager"

    core = corelib

    local sql = [[
        create table if not exists users
        (
            id integer primary key autoincrement,
            username varchar(25) unique,
            role varchar(32)
        );
    ]]
    local result = core.db():exec(sql)
    if result ~= sqlite3.OK then
        error("Unable to initialize database for user manager (error code " .. result .. ")")
    end

    for count in core.db():urows("select count(*) from users") do
        print("User manager initialized with " .. count .. " users")
    end

    -- sudo is only to set up xtlbot. it shouldn't be used in production
    if config.sudo then
        print "!!! WARNING !!!"
        print "You have a sudo user set in config/config.lua"
        print("You should run \"!role " .. config.sudo .. " superadmin\" as soon as possible.")
        print "Then you can set sudo to nil."
    end
end

function users.get(name)
    if user_cache[name] then
        return user_cache[name]
    end

    local stm = core.db():prepare("select * from users where username = ?")
    stm:bind(1, name)
    for u in stm:nrows() do
        local user = {
            id = u.id,
            name = u.username,
            role = u.role
        }

        if name == config.sudo then
            user.role = "superadmin"
        end

        user_cache[name] = user
        return user
    end

    local user = {
        name = name,
        role = "user"
    }

    if name == config.sudo then
        user.role = "superadmin"
    end

    user_cache[name] = user
    return user
end

function users.persist(user)
    assert(type(user) == "table")

    if user.id then
        local stm = core.db():prepare("update users set username = ?, role = ? where id = ?")
        stm:bind(1, user.name)
        stm:bind(2, user.role)
        stm:bind(3, user.id)
        for _ in stm:urows() do end
    else
        local stm = core.db():prepare("insert into users (username, role) values (?, ?)")
        stm:bind(1, user.name)
        stm:bind(2, user.role)
        for _ in stm:urows() do end

        -- need to fix this
        stm = core.db():prepare("select id from users where username = ?")
        stm:bind(1, user.name)
        for id in stm:urows() do
            user.id = id
        end
    end
end

function users.has_permission(user, permission)
    assert(type(user) == "table")
    assert(type(permission) == "string")

    return users.role_has_permission(user.role, permission)
end

function users.role_has_permission(role, permission)
    if type(role) == "string" then
        role = roles[role]
    end

    assert(type(role) == "table")

    for _,v in ipairs(role.permissions) do
        if v == permission then
            return true
        end
    end

    if not role.inherits then return false end

    for _,inherited in ipairs(role.inherits) do
        if(users.role_has_permission(inherited, permission)) then return true end
    end

    return false
end

return users