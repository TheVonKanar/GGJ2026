---@class ComponentSet
---@field Movement Movement

---@class Movement : Component
---@field vel number
---@field dir _Vector2D
---@field targetId integer
---@overload fun(data:table, targetId:integer)
Movement = class("Movement").extends(Component) or Movement
MOVEMENT = Movement.className

local geo <const> = playdate.geometry

function Movement:init(data, targetId)
   Movement.super.init(self)
   self.vel = data.velocity
   self.dir = geo.vector2D.new(0, 0)
   self.targetId = targetId
end

---@param entityId integer
---@return Movement
function Movement.get(entityId)
   return World:getComponent(entityId, MOVEMENT)
end

function Movement:__tostring()
   return string.format("Movement [velocity=%q|direction=%q|targetId=%q]", self.vel, self.dir, self.targetId)
end
