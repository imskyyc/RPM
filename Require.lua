local RunService = game:GetService("RunService")

return function(Module: string | Instance, FromFramework: boolean | nil): any | nil
    if typeof(Module) == "Instance" then
        return require(Module);
    else
        if FromFramework and RunService:IsClient() then
            FromFramework = nil;
        end

        local Source = debug.info(2, "s");

        local SourceTree = string.split(Source, ".");
        local Service    = game:GetService(SourceTree[1]);

        local ActiveBranch = game;
        for _, Branch: Instance in ipairs(SourceTree) do
            ActiveBranch = ActiveBranch[Branch];
        end

        for I=1, #SourceTree do
            ActiveBranch = ActiveBranch.Parent;

            if FromFramework then
                local Packages = ActiveBranch:FindFirstChild("Packages");
                local Utility  = ActiveBranch:FindFirstChild("Utility");

                if Packages and Utility then
                    local Package = Packages:FindFirstChild(Module);
                    local Utility = Utility:FindFirstChild(Module);

                    if Package then return require(Package)
                    elseif Utility then return require(Utility) end
                end
            else
                local Dependencies = ActiveBranch:FindFirstChild("Dependencies")
                if Dependencies then
                    local Instance = Dependencies:FindFirstChild(Module);

                    if Instance then return require(Instance) end
                end
            end
        end

        return nil;
    end
end