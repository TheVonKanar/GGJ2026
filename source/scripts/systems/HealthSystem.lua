---@class HealthSystem : System
HealthSystem = class("HealthSystem").extends(System) or HealthSystem

local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

function HealthSystem:init()
   HealthSystem.super.init(self)
end

function HealthSystem:update()
   local ids, sets = World:getComponentSets({ HEALTH })
   for i, set in ipairs(sets) do
      if set.Health.currentHealth <= 0 then
         World:destroyEntity(ids[i])
      end
   end
end

function HealthSystem:render()
   local _, sets = World:getComponentSets({ HEALTH, POSITION, RENDERER })
   for _, set in ipairs(sets) do
      if not set.Health.hasHealthBar then
         goto continue
      end

      local ratio = set.Health.currentHealth / set.Health.maxHealth
      local sprite = set.Renderer.sprite
      local w, h = sprite:getSize()
      local x, y = sprite:getPosition()

      -- Border.
      local rect = geo.rect.new(x - w * 0.5, y + h * 0.5 + 2, w, 4)
      gfx.drawRect(rect)

      -- Fill.
      rect.width *= ratio
      gfx.fillRect(rect)

      ::continue::
   end
end
