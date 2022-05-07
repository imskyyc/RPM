-- return setmetatable({}, {
--     __index = function(self, Index)
--         local CachedService = rawget(self, Index)

--         if CachedService then
--             return CachedService
--         else
--             local Exists, Service = pcall(game.GetService, game, Index)

--             if Exists then
--                 self[Index] = Service
--                 return Service
--             else
--                 return false
--             end
--         end
--     end,

--     __call = function(self)
--         return self
--     end
-- })

return setmetatable({}, {
    __index = function(Self, Index)
        local CachedService = rawget(Self, Index);

        if CachedService then return CachedService end

        
    end
})