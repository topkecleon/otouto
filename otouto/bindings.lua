--[[
    bindings.lua (rev. 2018/04/12)
    otouto's bindings for the Telegram bot API.
    https://core.telegram.org/bots/api
    See the "Bindings" section of README.md for usage information.

    Copyright 2018 topkecleon <drew@otou.to>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
    IN THE SOFTWARE.
]]--

local bindings = {}

local https = require('ssl.https')
local json = require('dkjson')
local ltn12 = require('ltn12')
local mp = require('multipart-post')

function bindings.set_token(token)
    bindings.BASE_URL = 'https://api.telegram.org/bot' .. token .. '/'
    return bindings
end

 -- Build and send a request to the API.
 -- Expecting method, parameters, and ?file, where method is a string indicating
 -- the API method and parameters is a key/value table of parameters with their
 -- values. Optional file is a table of a key/value pair of the file type (eg
 -- photo, document, video) and its location on-disk. The pair should be in
 -- parameters instead if the desired file is a URL or file ID.
 -- Returns true, response on success. Returns false, response on failure.
 -- Returns nil on a connection failure. Errs on invalid methods.
function bindings.request(method, parameters, file)
    parameters = parameters or {}
    for k,v in pairs(parameters) do
        parameters[k] = tostring(v)
    end
    if file and next(file) then
        local file_type, file_name = next(file)
        local file_file = io.open(file_name, 'r')
        local file_data = {
            filename = file_name,
            data = file_file:read('*a')
        }
        file_file:close()
        parameters[file_type] = file_data
    end
    if next(parameters) == nil then
        parameters = {''}
    end
    local response = {}
    local body, boundary = mp.encode(parameters)
    local success, code = https.request{
        url = bindings.BASE_URL .. method,
        method = 'POST',
        headers = {
            ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
            ["Content-Length"] = #body,
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response)
    }
    if not success then
        io.write(method .. ': Connection error. [' .. code  .. ']\n')
        return
    else
        local result = json.decode(table.concat(response))
        if not result then
            io.write('Invalid response.\n' .. table.concat(response) .. '\n')
            return
        elseif result.ok then
            return true, result
        elseif result.description == 'Method not found' then
            error(method .. ': Method not found.')
        else
            return false, result
        end
    end
end

function bindings.gen(_, key)
    return function(params, file)
        return bindings.request(key, params, file)
    end
end
setmetatable(bindings, { __index = bindings.gen })

return bindings
