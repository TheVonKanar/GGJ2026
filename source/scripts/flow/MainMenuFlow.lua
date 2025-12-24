---@class MainMenuFlow
MainMenuFlow = {}

function MainMenuFlow:enter()
end

function MainMenuFlow:leave()
end

function MainMenuFlow:update()
   local pd <const> = playdate

   pd.graphics.drawTextAligned("TEMPLATE", 200, 80, kTextAlignment.center)

   if pd.buttonJustPressed(pd.kButtonA) then
      FlowManager:setState(GameFlow)
   end
end
