---@class ComponentSet
---@field Collider Collider

---@class Collider : Component
---@field width integer
---@field height integer
---@field radius integer
Collider = class("Collider").extends(Component) or Collider
COLLIDER = Collider.className

function Collider:init(data)
   Collider.super.init(self)
   self.width = data.width
   self.height = data.height
   self.radius = data.radius
   self.collisions = {}
end

function Collider:__tostring()
   return COLLIDER
end

---@param entityId integer
---@return Collider
function Collider.get(entityId)
   return World:getComponent(entityId, COLLIDER)
end
