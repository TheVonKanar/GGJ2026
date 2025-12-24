---@class MovementSystem : System
MovementSystem = class("MovementSystem").extends(System) or MovementSystem

local geo <const> = playdate.geometry

function MovementSystem:init()
   MovementSystem.super.init(self)
   self.renderCommands = {}
end

function MovementSystem:update()
   -- Move all moveable entities with collisions first.
   local ids, sets = World:getComponentSets({ POSITION, MOVEMENT, RENDERER })
   for i, set in ipairs(sets) do
      local position = set.Position
      local movement = set.Movement
      local renderer = set.Renderer

      -- Compute direction if a target is set.
      local targetPosition = Position.get(movement.targetId)
      if targetPosition then
         movement.dir = (targetPosition.point - position.point):normalized()
      end

      -- Compute goal position.
      local goalPoint = position.point:offsetBy((movement.dir * movement.vel):unpack())

      -- Compute actual new position.
      local newPoint = nil
      local collider = Collider.get(ids[i])
      if collider then
         local actualX, actualY, collisions, _ = renderer.sprite:checkCollisions(goalPoint)
         newPoint = geo.point.new(actualX, actualY)
         collider.collisions = collisions
      else
         newPoint = goalPoint
      end

      if newPoint ~= position.point then
         position.point = newPoint
         self.renderCommands[renderer.sprite] = newPoint
      end
   end
end

function MovementSystem:render()
   for sprite, point in pairs(self.renderCommands) do
      sprite:moveTo(point)
   end
   self.renderCommands = {}
end
