---@class ComponentSet
---@field Attack Attack

---@class Attack : Component
---@field range number
---@field damage number
---@field speed number
---@field targets string[]
Attack = class("Attack").extends(Component) or Attack
ATTACK = Attack.className

function Attack:init(data)
   Attack.super.init(self)

   self.range = data.range
   self.damage = data.damage
   self.speed = data.speed
   self.targets = data.targets

   self.closestTargetId = 0
   self.lastTriggerTime = -999
end

function Attack:__tostring()
   return ATTACK
end

---@param entityId integer
---@return Attack
function Attack.get(entityId)
   return World:getComponent(entityId, ATTACK)
end
