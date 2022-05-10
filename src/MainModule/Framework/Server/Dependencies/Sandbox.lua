--[[

    imskyyc
    RPM Package Sandbox Wrapper
    5/9/2022 @ 9:36 AM

    will do in future

]]--

type Function   = (...any?) -> any;

local This = script
local Sandbox = {}
Sandbox.__index = Sandbox

local ServiceEmulator = require(This.Parent.ServiceEmulator)

--// Game Emulation
local game = game --// Because apparently storing game in a variable is about 10% faster
local Game = {}
Game.__index = Game

function Game.new(Services: Dictionary<string>, Plugin: {}, Shared: {}, _G: {})
    local game: DataModel = setmetatable({
        CreatorId   = game.CreatorId,
        CreatorType = game.CreatorType,
        GameId      = game.GameId,
        -- Genre       = game.Genre,
            
        JobId                = game.JobId,
        PlaceId              = game.PlaceId,
        PlaceVersion         = game.PlaceVersion,
        PrivateServerId      = game.PrivateServerId,
        PrivateServerOwnerId = game.PrivateServerOwnerId,
        Workspace            = {},

        Services = Services,
        Plugin   = Plugin,
        Shared   = Shared,
        _G       = _G,
    
        Archivable = game.Archivable,
        ClassName  = game.ClassName,
        Name       = game.Name,
        Parent     = nil,
    }, Game)

    return game;
end

function Game:BindToClose(Functon: Function): nil

end

function Game:GetJobsInfo(): Array<any>

end

function Game:GetObjects(): ...any

end

function Game:IsLoaded(): boolean
    return game.IsLoaded
end

function Game:GetService(ClassName: string): Instance
    return self.Services[ClassName]
end

function Game:FindService(ClassName: string): Instance
    return self:GetService(ClassName)
end



function Sandbox.new(Function: Function, Intents: Dictionary<string>): Dictionary<string>
    local Services  = {}
    local plugin    = {}
    local shared    = {}
    local _G        = shared
    
    for _, Service in pairs(Intents.services) do
        Services[Service] = ServiceEmulator.new(Service)
    end

    local game = Game.new(Services, plugin, shared, _G)

    local SandboxedFunction = setmetatable({
        game      = game,
        plugin    = plugin,
        shared    = shared,
        workspace = workspace,
        _G        = _G,
        intents   = Intents
    }, Sandbox);

    return setfenv(Function, SandboxedFunction);
end

return Sandbox