---@class PlayerSystem : System
PlayerSystem = class("PlayerSystem").extends(System) or PlayerSystem

local pd <const> = playdate
local geo <const> = playdate.geometry

function PlayerSystem:init()
   PlayerSystem.super.init(self)
end

function PlayerSystem:load()
   PlayerSystem.super.load(self)
   self:spawnPlayer()
end

function PlayerSystem:update()
   self:updateInputs()
end

function PlayerSystem:updateInputs()
   local movement = Movement.get(World.playerId)
   movement.dir.dx = 0
   movement.dir.dy = 0
   if pd.buttonIsPressed(pd.kButtonUp) then
      movement.dir.dy -= 1
   end
   if pd.buttonIsPressed(pd.kButtonDown) then
      movement.dir.dy += 1
   end
   if pd.buttonIsPressed(pd.kButtonLeft) then
      movement.dir.dx -= 1
   end
   if pd.buttonIsPressed(pd.kButtonRight) then
      movement.dir.dx += 1
   end
end

function PlayerSystem:spawnPlayer()
   local data = DataManager:getData("data/player")

   -- Setup Player.
   local player = Player()

   -- Setup Renderer.
   local renderer = Renderer(data.renderer)
   renderer.sprite:setTag(PLAYER_TAG)

   -- Setup Position.
   local x = pd.display.getWidth() * 0.5
   local y = pd.display.getHeight() * 0.5
   local position = Position(geo.point.new(x, y))
   renderer.sprite:moveTo(x, y)

   -- Setup Collider.
   local collider = Collider(data.collider)
   renderer.sprite:setCollideRect(0, 0, collider.width, collider.height)

   -- Setup Movement.
   local movement = Movement(data.movement, 0)

   -- Setup Health
   local health = Health(data.health)

   -- Setup Attack.
   local attack = Attack(data.attack)

   -- Create Entity.
   World.playerId = World:createEntity({ player, renderer, position, collider, movement, health, attack })
end
