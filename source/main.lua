---- IMPORTS ----

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/utils/typeof"
import "scripts/utils/random"
import "scripts/utils/StringBuilder"

import "scripts/core/Entity"
import "scripts/core/Component"
import "scripts/core/ComponentSet"
import "scripts/core/System"
import "scripts/core/World"
import "scripts/core/Archetype"

import "scripts/components/Collider"
import "scripts/components/Movement"
import "scripts/components/Player"
import "scripts/components/Position"
import "scripts/components/Renderer"
import "scripts/components/Attack"
import "scripts/components/Health"

import "scripts/managers/DataManager"
import "scripts/managers/FlowManager"

import "scripts/flow/MainMenuFlow"
import "scripts/flow/GameFlow"

import "scripts/systems/MovementSystem"
import "scripts/systems/PlayerSystem"
import "scripts/systems/AttackSystem"
import "scripts/systems/HealthSystem"

---- LOCALS ---

local pd <const> = playdate
local gfx <const> = playdate.graphics

---- INIT ----

DataManager:init()
FlowManager:init()

FlowManager:setState(MainMenuFlow)

---- UPDATE LOOP ----

function pd.update()
   gfx.clear()
   gfx.sprite.update()
   pd.timer.updateTimers()

   World:update()

   FlowManager:update()

   -- Uncomment this to show fps in the top left corner.
   -- gfx.drawText(tostring(pd.getFPS()), 4, 4)
end
