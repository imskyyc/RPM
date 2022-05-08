--[[

    imskyyc
    RPMLua HTTP Module
    5/8/2022 @ 9:14 AM

    Copyright (C) 2022 imskyyc

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    
]]--

local CoreInstance = script
local Core = require(CoreInstance.Parent.Parent.Parent.Common.Core)

local Server, Service
local PCall, CPCall, require

local print, warn, error, debug

local self; self = Core.new("HTTP", {
    Load = function(Environment: Dictionary<string>) 
        Server  = Environment.Server
        Service = Environment.Service

        PCall   = Environment.PCall
        CPCall  = Environment.CPCall
        require = Environment.require

        print = Environment.print
        warn  = Environment.warn
        error = Environment.error
        debug = Environment.debug

        --// TODO: HTTP stuff, will come in later update
    end,

    Request = function(URL: string, Method: string, Headers: Dictionary<string>, Body: Dictionary<string>, Decode: boolean): Dictionary<string>
        local HttpService: HttpService = Service.HttpService

        local Request = {
            Url     = URL,
            Method  = Method,
            Headers = Headers,
            Body    = if Method ~= "GET" and Method ~= "HEAD" then Body else nil
        }

        local Success, Response = PCall(HttpService.RequestAsync, false, HttpService, Request)

        if Success then
            if Decode then
                local Body = Response.body
                local Decoded, JSON = PCall(HttpService.JSONDecode, false, HttpService, Body)

                if Decoded and JSON then
                    return JSON
                else
                    return {}
                end
            else
                return Response
            end
        end
    end,

    Logging = {
        
    }
})

return self;