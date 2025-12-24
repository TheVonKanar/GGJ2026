---@class ComponentSet
---@field Position Position

---@class Position : Component
---@field point _Point
Position = class("Position").extends(Component) or Position

POSITION = Position.className

function Position:init(point)
   Position.super.init(self)
   self.point = point
end

function Position:__tostring()
   return string.format("Position [point=%q]", self.point)
end

---@param entityId integer
---@return Position
function Position.get(entityId)
   return World:getComponent(entityId, POSITION)
end
