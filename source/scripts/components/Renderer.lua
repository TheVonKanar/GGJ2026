---@class ComponentSet
---@field Renderer Renderer

---@class Renderer : Component
Renderer = class("Renderer").extends(Component) or Renderer
RENDERER = Renderer.className

local gfx <const> = playdate.graphics

function Renderer:init(data)
   Renderer.super.init(self)
   local image = gfx.image.new(data.image)
   self.sprite = gfx.sprite.new(image)
   self.sprite:add()
end

function Renderer:release()
   self.sprite:remove()
end

function Renderer:__tostring()
   return RENDERER
end

---@param entityId integer
---@return Renderer
function Renderer.get(entityId)
   return World:getComponent(entityId, RENDERER)
end
