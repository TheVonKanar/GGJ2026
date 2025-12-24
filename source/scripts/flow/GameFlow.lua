---@class GameFlow
GameFlow = {}

function GameFlow:enter()
   World:load({
      PlayerSystem(),
      AttackSystem(),
      HealthSystem(),
      MovementSystem(),
   })
end

function GameFlow:leave()
   World:unload()
end

function GameFlow:update()
   if not World.entities[World.playerId].alive then
      FlowManager:setState(MainMenuFlow)
   end
end
