---@class ComponentSet
---@field Health Health

---@class Health : Component
---@field currentHealth number
---@field maxHealth number
---@field hasHealthBar boolean
Health = class("Health").extends(Component) or Health
HEALTH = Health.className

function Health:init(data)
   Health.super.init(self)
   self.maxHealth = data.maxHealth
   self.currentHealth = self.maxHealth
   self.hasHealthBar = data.hasHealthBar
end

function Health:__tostring()
   return HEALTH
end

---@param entityId integer
---@return Health
function Health.get(entityId)
   return World:getComponent(entityId, HEALTH)
end
