---@class ComponentSet
---@field Player Player

---@class Player : Component
Player = class("Player").extends(Component) or Player
PLAYER = Player.className
PLAYER_TAG = World:registerTag(PLAYER)

function Player:init()
   Player.super.init(self)
end

function Player:__tostring()
   return PLAYER
end

---@param entityId integer
---@return Player
function Player.get(entityId)
   return World:getComponent(entityId, PLAYER)
end
