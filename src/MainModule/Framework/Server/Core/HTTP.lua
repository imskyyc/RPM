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
    end
})

return self;