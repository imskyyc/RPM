local LocalizationService = game:GetService("LocalizationService")
local MarketplaceService = game:GetService("MarketplaceService")
local VRService = game:GetService("VRService")
local ServerScriptService = game:GetService("ServerScriptService")
return {
    services = {
        Workspace           = true,
        Players             = true,
        Lighting            = true,
        MaterialService     = true,
        NetworkClient       = true,
        ReplicateFirst      = true,
        ReplicatedStorage   = true,
        ServerScriptService = true,
        ServerStorage       = true,
        StarterGui          = true,
        StarterPack         = true,
        StarterPlayer       = true,
        Teams               = true,
        Chat                = true,
        SoundService        = true,
        TextChatService     = true,
        LocalizationService = true,
        TestService         = true,
        Debris              = true,
        InsertService       = true,
        MarketplaceService  = true,
        RunService          = true,
        VRService           = true,
    },
    loadable = true,
    server = true,
    client = true,
}