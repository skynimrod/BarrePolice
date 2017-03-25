--[[
    Copyright 2017 wrxck <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]

local obama = {}

local mattata = require('mattata')

function obama:init()
    obama.commands = mattata.commands(
        self.info.username
    ):command('obama').table
    obama.help = '/obama - Sends a random, badly-drawn photo of Barack Obama.'
end

function obama:on_message(message, configuration)
    local success = mattata.send_photo(
        message.chat.id,
        'http://iamchriscollins.com/badpaintingsofbarackobama/images/' .. math.random(47) .. '.jpg'
    )
    if not success then
        return mattata.send_reply(
            message,
            configuration.errors.connection
        )
    end
    return
end

return obama