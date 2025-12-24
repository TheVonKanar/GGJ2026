---@class AttackSystem : System
AttackSystem = class("AttackSystem").extends(System) or AttackSystem

local pd <const> = playdate

function AttackSystem:init()
   AttackSystem.super.init(self)
end

function AttackSystem:update()
   local ids, sets = World:getComponentSets({ ATTACK, POSITION })
   for i, set in ipairs(sets) do
      local attack = set.Attack

      -- Compute closest target.
      local closestTargetDist = 999999
      attack.closestTargetId = 0
      for _, target in ipairs(attack.targets) do
         local ids, targetSets = World:getComponentSets({ target, POSITION, COLLIDER, HEALTH })
         for i, targetSet in ipairs(targetSets) do
            local dist = set.Position.point:distanceToPoint(targetSet.Position.point)
            if dist < closestTargetDist then
               closestTargetDist = dist
               attack.closestTargetId = ids[i]
            end
         end
      end

      -- Trigger Attack if ready.
      local time = pd.getElapsedTime()
      local delay = (1 / attack.speed)
      if time - attack.lastTriggerTime > delay then
         self:triggerAttack(ids[i])
         attack.lastTriggerTime = time
      end
   end
end

---@param attackerId integer
function AttackSystem:triggerAttack(attackerId)
   local attackerSet = World:getComponentSet(attackerId, { ATTACK, POSITION, COLLIDER })
   if not attackerSet then return end

   local targetSet = World:getComponentSet(attackerSet.Attack.closestTargetId, { POSITION, HEALTH, COLLIDER })
   if not targetSet then return end

   local dist = attackerSet.Position.point:distanceToPoint(targetSet.Position.point)
   local range = attackerSet.Attack.range + attackerSet.Collider.radius + targetSet.Collider.radius
   if dist > range then return end

   targetSet.Health.currentHealth -= attackerSet.Attack.damage
end
