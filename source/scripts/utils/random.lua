local geo <const> = playdate.geometry

random = {}

math.randomseed(playdate.getSecondsSinceEpoch())

---Return a random position anywhere on the edges of the given rect.
---@param rect playdate.geometry.rect
---@return playdate.geometry.point
function random.randomPointOnRect(rect)
   local result = geo.point.new(0, 0)
   local x, y, w, h = rect:unpack()

   if w <= 0 and h <= 0 then return result end

   local ratio = w / (w + h)
   if math.random() < 0.5 then
      -- top or left
      if math.random() < ratio then
         -- top
         result.x = math.random(x, w)
         result.y = y
      else
         -- left
         result.x = x
         result.y = math.random(y, h)
      end
   else
      -- bottom or right
      if math.random() < ratio then
         -- bottom
         result.x = math.random(x, w)
         result.y = h
      else
         -- right
         result.x = w
         result.y = math.random(y, h)
      end
   end

   return result
end
