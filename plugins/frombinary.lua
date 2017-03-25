--[[
    Copyright 2017 wrxck <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]

local frombinary = {}

local mattata = require('mattata')
local redis = require('mattata-redis')

function frombinary:init()
    frombinary.commands = mattata.commands(
        self.info.username
    ):command('frombinary')
     :command('frombin').table
    frombinary.help = '/frombinary <binary> - Converts the given binary to its string value. Alias: /frombin.'
end

function frombinary.split(bin, delimiter)
    local output = {}
    local pos = 1
    local from, to = string.find(
        bin,
        delimiter,
        pos
    )
    while from do
        table.insert(
            output,
            string.sub(
                bin,
                pos,
                from - 1
            )
        )
        pos = to + 1
        from, to = string.find(
            bin,
            delimiter,
            pos
        )
    end
    table.insert(
        output,
        string.sub(
            bin,
            pos
        )
    )
    return output
end

function frombinary.bin_to_str(bin)
    local output = ''
    for k, v in pairs(
        frombinary.split(
            bin,
            '\n'
        )
    ) do
        q = 1
        for i = 1, #v / 8 do
            output = output .. string.char(
                tonumber(
                    string.sub(
                        v,
                        q,
                        q + 7
                    ),
                    2
                )
            )
            q = q + 8
        end
    end
    return output ~= '' and output or 'Malformed binary!'
end

function frombinary:on_message(message, configuration)
    local input = mattata.input(message.text)
    if not input then
        local success = mattata.send_force_reply(
            message,
            'Please enter the binary value you would like to convert to a string.'
        )
        if success then
            redis:set(
                string.format(
                    'action:%s:%s',
                    message.chat.id,
                    success.result.message_id
                ),
                '/frombinary'
            )
        end
        return
    end
    return mattata.send_message(
        message.chat.id,
        string.format(
            '<pre>%s</pre>',
            frombinary.bin_to_str(
                input:gsub('\n', ''):gsub('%s', '')
            )
        ),
        'html'
    )
end

return frombinary