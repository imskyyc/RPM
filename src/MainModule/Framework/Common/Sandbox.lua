--[[

    imskyyc
    RPM Package Sandbox Wrapper
    5/9/2022 @ 9:36 AM

    will do in future

]]--

type Function   = (...any?) -> any;

local Sandbox = {}
Sandbox.__index = Sandbox

--// Script Globals
local TaskScheduler: {[number]: any?} = {}
local game = game --// Because apparently storing game in a variable is about 10% faster
local workspace = {}
local game: DataModel = {
    CreatorId   = game.CreatorId,
    CreatorType = game.CreatorType,
    GameId      = game.GameId,
    -- Genre       = game.Genre,
        
    JobId                = game.JobId,
    PlaceId              = game.PlaceId,
    PlaceVersion         = game.PlaceVersion,
    PrivateServerId      = game.PrivateServerId,
    PrivateServerOwnerId = game.PrivateServerOwnerId,
    Workspace            = workspace,

    Archivable = game.Archivable,
    ClassName  = game.ClassName,
    Name       = game.Name,
    Parent     = nil,
}

--// Define game functions
local CloseFunctions: {[number]: Function} = {}
function game:BindToClose(Function: Function)
    table.insert(CloseFunctions, Function)
end

function game:GetJobsInfo(): {[number]: any?}
    return TaskScheduler
end

local plugin    = {}
local shared    = {}
local _G        = {}

function Sandbox.new(Module: ModuleScript): Dictionary<string>
    return setfenv(1, {
        game      = game,
        plugin    = plugin,
        shared    = shared,
        workspace = workspace,
        _G        = _G,
    })
end

return Sandbox