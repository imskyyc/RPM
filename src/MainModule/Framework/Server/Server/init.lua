--[[

    imskyyc
    RPM Server
    5/4/2022 @ 9:39 PM PST

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

-- Types --
export type Function   = (...any?) -> any;
export type Array      = {[number]: any};
export type Dictionary = {[string]: any};

-- Old Script Globals --
local oldPrint = print;
local oldWarn  = warn;
local oldError = error;
local oldDebug = debug;

-- Instances --
local Runner       = script --// Using script.Parent is ugly to me
local Folder       = Runner.Parent
local Core         = Folder.Core
local Dependencies = Folder.Dependencies
local Framework    = Folder.Parent
local MainModule   = Framework.Parent
local Packages     = MainModule.Packages

local Config = require(MainModule.Configuration); MainModule.Configuration:Destroy();
local Client = Framework.Client
local Common = Framework.Common

-- Override Script Globals --
local debug = {output  = function(...) local Calling, LineNumber, FunctionName = debug.info(2, "sln") local OutputEnabled = Config.framework.debug; if OutputEnabled then for _, Message in ipairs({...}) do warn(string.format("{ Server : %s : DEBUG }:", tostring(Calling)), Message, string.format("{ Function %s : Line %d }", (FunctionName or "Unknown"), LineNumber)) end end end,}
local print = function(...) local Calling, LineNumber, FunctionName = debug.info(2, "sln") for _, Message in ipairs({...}) do print(string.format("{ Server : %s : INFO }:", tostring(Calling)), Message, string.format("{ Function %s : Line %d }", (FunctionName or "Unknown"), LineNumber)) end end
local warn  = function(...) local Calling, LineNumber, FunctionName = debug.info(2, "sln") for _, Message in ipairs({...}) do warn(string.format("{ Server : %s : WARN }:", tostring(Calling)), Message, string.format("{ Function %s : Line %d }", (FunctionName or "Unknown"), LineNumber)) end end
local error = function(...) local Calling, LineNumber, FunctionName = debug.info(2, "sln") local OutputEnabled = Config.framework.error_handling.output_to_console; if OutputEnabled then for _, Message in ipairs({...}) do warn(string.format("{ Server : %s : ERROR }:", tostring(Calling)), Message, string.format("{ Function %s : Line %d }", (FunctionName or "Unknown"), LineNumber)) end end end

--// Add old debug functions
for Key, Value in pairs(oldDebug) do debug[Key] = Value end

-- Functions --
local PCall = function(Function: Function, Critical: boolean, ...): (boolean, string)
    local Ran, Return = pcall(Function, ...)
    
    if Ran then
        return Ran, Return
    else
        local ErrorConfig = Config.framework.error_handling
        
        error(Return)
        
        if ErrorConfig.mode == "rpm" then
            --// TODO: HTTP Requests
        elseif ErrorConfig.mode == "sentry" then
            --// TODO: HTTP Requests + Sentry support
        else
            warn("Error Handling output mode is invalid. Expected: \"rpm\" or \"sentry\"; got: \"" .. ErrorConfig.mode .. "\"")
        end

        return false, Return
    end
end

local CPCall = function(Function: Function, Critical: boolean, ...): nil
    return coroutine.wrap(PCall)(Function, Critical, ...)
end

local package_cache = {}
local require_cache = {}
local require = function(Module: Instance | string): any?
    --// We need to override the built-in require function so we can source
    --// modules from the Dependencies folder by default

    local do_require = function(Module: Instance | string): any?
        local Required, Return = PCall(require, false, Module)

        if Required then
            require_cache[Module] = Return
            return Return
        end
    end

    if require_cache[Module] then
        return require_cache[Module]
    elseif typeof(Module) == "Instance" then
        return do_require(Module)
    elseif package_cache[Module] then
        return package_cache[Module]
    else
        local Dependency = Dependencies:FindFirstChild(Module)

        if Dependency then
            return do_require()
        else
            warn("Attempted to require invalid dependency. Got: \"" .. Module .. "\"")
        end
    end

    return nil
end

-- Setup -- 
local Server   = {}
local Service  = setmetatable({}, {__index = function(Self, Index) local CachedService = rawget(Self, Index); if CachedService then return CachedService end local Valid, Service = pcall(game.GetService, game, Index); if Valid and Service then Self[Index] = Service return Service else return nil end end})

local Environment = {
    Server   = Server,
    Service  = Service,
    Packages = Packages,

    MainModule   = MainModule,
    Framework    = Framework,
    Core         = Core,
    Dependencies = Dependencies,

    Client       = Client,
    Common       = Common,

    PCall   = PCall,
    CPCall  = CPCall,
    require = require,

    print = print,
    warn  = warn,
    error = error,
    debug = debug,

    oldPrint = oldPrint,
    oldWarn  = oldWarn,
    oldError = oldError,
    oldDebug = oldDebug
}

-- Load --
Server.Load = function()
    print("RPMLua Copyright (C) 2022 imskyyc")
    print("Beginning RPM Framework loading process...")

    debug.output("Checking for existing RPM instance...")
    if _G.RPM and Config.framework.prevent_multiple_instances then
        return error("RPM is already running! Aborting load process.");
    else
        _G.RPM = true
    end

    debug.output("Loading cores...")

    for _, Core in pairs(Core:GetChildren()) do --// Register the core parts of the framework
        local CoreObject = require(Core)

        CoreObject:SetEnvironment(Environment)

        Server[Core.Name] = CoreObject

        debug.output("Core: " .. CoreObject.Name .. " registered.")
    end

    for _, Core in pairs(Core:GetChildren()) do --// Load the registered cores
        local Core = Server[Core.Name]
        
        if Core then
            Core:LoadCore()
            debug.output("Core: " .. Core.Name .. " loaded.")
        end
    end
    
    debug.output("Cores loaded successfully.")

    debug.output("Destroying Core Folder...")
    Core:Destroy() --// Delete unused instances for optimization.

    --// Load packages & dependencies to server and client
    debug.output("Start package loading...")

    local WrappedPackage = require(Common.Package)
    for _, Package in pairs(Packages:GetChildren()) do
        local PackageInfo = require(Package)

        if typeof(PackageInfo) == "table" then
            local PackageType    = PackageInfo.type
            local PackageIntents = PackageInfo.intents
            --// load other stuff about the package


            --// why no switch statement :(
            if PackageIntents.server then
                if PackageType == "dependency" then
                    Package:Clone().Parent = Dependencies
                    
                    continue
                elseif PackageType == "package" then
                    local Package = WrappedPackage.new(PackageInfo)
                    package_cache[Package.Name] = Package

                    if Package.Intents.loadable and Package.Load then
                        Package.Load(Environment) 
                    end
                else
                    warn("Server Package: " .. Package.Name .. " attempted to load with an invalid type. Expected: dependency / package; got: " .. PackageInfo.type)
                end
            end

            if PackageIntents.client then
                if PackageType == "dependency" then
                    Package:Clone().Parent = Client.Dependencies
                    
                    continue
                elseif PackageType == "package" then
                    Package:Clone().Parent = Client.Packages

                    continue
                else
                    warn("Client Package: " .. Package.Name .. " attempted to load with an invalid type. Expected: dependency / package; got: " .. PackageInfo.type)
                end
            end
        end
    end

    debug.output("Packages loaded successfully.")

    print("RPM Framework successfully loaded.")
end

return Server