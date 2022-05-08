--[[

    imskyyc
    RPM Server
    5/4/2022 @ 9:39 PM PST

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

local Config = require(MainModule.Configuration); MainModule.Configuration:Destroy();
local Client = Framework.Client
local Common = Framework.Common

-- Override Script Globals --
local print = function(...) local Calling, LineNumber, FunctionName = debug.info(2, "sln") for _, Message in ipairs({...}) do print(string.format("{ Server : %s : INFO }:", tostring(Calling)), Message, string.format("{ Function %s : Line %d }", (FunctionName or "Unknown"), LineNumber)) end end
local warn  = function(...) local Calling, LineNumber, FunctionName = debug.info(2, "sln") for _, Message in ipairs({...}) do warn(string.format("{ Server : %s : WARN }:", tostring(Calling)), Message, string.format("{ Function %s : Line %d }", (FunctionName or "Unknown"), LineNumber)) end end
local error = function(...) local Calling, LineNumber, FunctionName = debug.info(2, "sln") local OutputEnabled = Config.framework.error_handling.output_to_console; if OutputEnabled then for _, Message in ipairs({...}) do warn(string.format("{ Server : %s : ERROR }:", tostring(Calling)), Message, string.format("{ Function %s : Line %d }", (FunctionName or "Unknown"), LineNumber)) end end end

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

local require_cache = {}
local require = function(Module: Instance | string): any?
    --// We need to override the built-in require function so we can source
    --// modules from the Dependencies folder by default

    if require_cache[Module] then
        return require_cache[Module]
    elseif typeof(Module) == "Instance" then
        local Required, Return = PCall(require, false, Module)

        if Required then
            require_cache[Module] = Return
            return Return
        end
    else
        local Dependency = Dependencies:FindFirstChild(Module)

        if Dependency then
            local Required, Return = PCall(require, false, Module)

            if Required then
                require_cache[Module] = Return
                return Return
            end

        else
            warn("Attempted to require invalid dependency. Got: \"" .. Module .. "\"")
        end
    end

    return nil
end

-- Setup -- 
local Server  = {}
local Service = setmetatable({}, {__index = function(Self, Index) local CachedService = rawget(Self, Index); if CachedService then return CachedService end local Valid, Service = pcall(game.GetService, game, Index); if Valid and Service then Self[Index] = Service return Service else return nil end end})

local Environment = {
    Server  = Server,
    Service = Service,

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

    for _, Core in pairs(Core:GetChildren()) do --// Register the core parts of the framework
        local CoreObject = require(Core)

        CoreObject:SetEnvironment(Environment)

        Server[Core.Name] = CoreObject

        --// TODO: Debug Outputs
    end

    for _, Core in pairs(Core:GetChildren()) do --// Load the registered cores
        local Core = Server[Core.Name]
        
        if Core then
            Core:LoadCore()
        end
    end

    Core:Destroy() --// Delete unused instances for optimization.

    --// Load packages & dependencies to server and client

    print("RPM Framework successfully loaded.")
end

return Server