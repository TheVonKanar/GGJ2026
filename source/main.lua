---- IMPORTS ----

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

---- DATA ----

import "masks"
import "menu"

local letters = { "A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P", "Q", "S", "D", "F", "G", "H", "J", "K", "L", "M", "W",
   "X", "C", "V", "B", "N" }

local banks = {
   json.decodeFile("words/6-letter-words.json"),
   json.decodeFile("words/7-letter-words.json"),
   json.decodeFile("words/8-letter-words.json"),
   json.decodeFile("words/9-letter-words.json")
}

---- LOCALS ----

local pd <const> = playdate
local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

local crankMul = 0.1

local rawGridY = 0
local gridY = 0
local rows = Menu
local cellWidth = 20
local cellHeight = 20
local maxRows = 64
local focusedRow1
local focusedRow2

---@class _Polygon
local maskPolygon
local mask
local maskX = cellWidth * 3
local maskY
local maskIndex = 1

local timerDuration = 5000
local score = 0

---- FUNCTIONS ----

local function createRow()
   local bankIndex = math.random(#banks)
   local bank = banks[math.random(bankIndex)]
   local word = string.upper(bank[math.random(#bank)])

   local row = { cells = {} }

   local wordSize = #word
   local gapSize = 10 - wordSize
   local gapStart = math.random(wordSize)
   for i = 1, #word do
      row.cells[i] = string.sub(word, i, i)
   end

   for i = gapStart, gapStart + gapSize - 1 do
      table.insert(row.cells, i, letters[math.random(#letters)])
   end

   row.gapSize = gapSize
   row.gapStart = gapStart
   row.wordSize = wordSize
   row.word = word
   return row
end

local function pickMask(i)
   mask = Masks[i]

   maskY = cellHeight * 6 - mask.size[2] * cellHeight

   local points = {}
   for _, p in ipairs(mask.polygon) do
      table.insert(points, geo.point.new(
         maskX + p[1] * cellWidth,
         maskY + p[2] * cellHeight))
   end
   maskPolygon = geo.polygon.new(table.unpack(points))
end

local function tryValidateRow(y)
   if y < 1 or y > #rows then
      return
   end
   local row = rows[y]
   local gapStart = nil
   local gapSize = 0
   for x = 1, #row.cells do
      local point = geo.point.new(
         (x - 1) * cellWidth,
         gridY + ((y - 1) * cellHeight) + 2
      ):offsetBy(cellWidth / 2, cellHeight / 2)

      if maskPolygon:containsPoint(point) then
         gapStart = gapStart or x
         gapSize = gapSize + 1
      end
   end

   if row.gapStart == gapStart and row.gapSize == gapSize then
      rows[y].isSolved = true
      rows[y].cells = { "G", "G", "}", "+", "1", "0", "0", "{", "G", "G", }
   end
end

local function onTimerEnd()
   pd.resetElapsedTime()

   if #rows == 0 then
      pd.restart()
      return
   end

   if rows[1].isMenu then
      score = score + 0
   elseif rows[1].isSolved then
      score = score + 100
   else
      score = score - 50
   end

   table.remove(rows, 1)
   rawGridY = rawGridY + cellHeight
   gridY = gridY + cellHeight
end

---- INIT ----

math.randomseed(playdate.getSecondsSinceEpoch())
pd.display.setScale(2)
gfx.setLineWidth(1)
gfx.setBackgroundColor(gfx.kColorBlack)

pickMask(maskIndex)

local timer = pd.timer.new(timerDuration, onTimerEnd)
timer.repeats = true

---- UPDATE LOOP ----

function pd.update()
   gfx.clear()
   gfx.sprite.update()
   pd.timer.updateTimers()

   --- INPUTS ---
   -- Crank (grid scrolling)
   local change, acceleratedChange = playdate.getCrankChange()
   rawGridY = rawGridY - change * crankMul
   local oldGridY = gridY
   gridY = math.floor((rawGridY / cellHeight) + 0.5) * cellHeight

   if focusedRow1 and focusedRow1 > 0 and focusedRow1 <= #rows then
      rows[focusedRow1].isFocused = false
   end
   focusedRow1 = math.floor((cellHeight * 6 - gridY) / cellHeight)
   if focusedRow1 and focusedRow1 > 0 and focusedRow1 <= #rows then
      rows[focusedRow1].isFocused = true
   end

   if focusedRow2 and focusedRow2 > 0 and focusedRow2 <= #rows then
      rows[focusedRow2].isFocused = false
   end
   if mask.size[2] > 1 then
      focusedRow2 = math.floor((cellHeight * 5 - gridY) / cellHeight)
   else
      focusedRow2 = -1
   end
   if focusedRow2 and focusedRow2 > 0 and focusedRow2 <= #rows then
      rows[focusedRow2].isFocused = true
   end

   -- Left / Right Arrows (mask horizontal movement)
   local maskBounds = maskPolygon:getBoundsRect()
   if pd.buttonJustPressed(pd.kButtonLeft) and
       maskBounds.right > cellWidth then
      maskPolygon:translate(-cellWidth, 0)
      maskX = maskX - cellWidth
   end

   if pd.buttonJustPressed(pd.kButtonRight) and
       maskBounds.left < 200 - cellWidth then
      maskPolygon:translate(cellWidth, 0)
      maskX = maskX + cellWidth
   end

   -- Up / Down Arrows (change mask)
   if pd.buttonJustPressed(pd.kButtonUp) then
      maskIndex = maskIndex - 1
      if maskIndex < 1 then
         maskIndex = #Masks
      end
      pickMask(maskIndex)
   end

   if pd.buttonJustPressed(pd.kButtonDown) then
      maskIndex = maskIndex + 1
      if maskIndex > #Masks then
         maskIndex = 1
      end
      pickMask(maskIndex)
   end

   -- A / B buttons (validate)
   if pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB) then
      tryValidateRow(focusedRow1)
      tryValidateRow(focusedRow2)
   end

   --- GRID MANAGEMENT ---
   if gridY < oldGridY then
      local delta = math.ceil((oldGridY - gridY) / cellHeight)
      for i = 1, delta do
         table.insert(rows, createRow())
      end

      if #rows > maxRows then
         for i = 1, #rows - maxRows do
            table.remove(rows, 1)
            rawGridY = rawGridY + cellHeight
            gridY = gridY + cellHeight
         end
      end
   end

   --- DRAW GRID ---
   gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
   for y, row in ipairs(rows) do
      for x = 1, #row.cells do
         local point = geo.point.new(
            (x - 1) * cellWidth,
            gridY + ((y - 1) * cellHeight) + 2
         )
         local center = point:offsetBy(cellWidth / 2, cellHeight / 2)
         if not maskPolygon:containsPoint(center) then
            local text = row.cells[x]
            if row.isMenu or row.isSolved or row.isFocused then
               text = "*" .. text .. "*"
            end

            gfx.drawText(
               text,
               point.x,
               point.y,
               cellWidth,
               cellHeight,
               gfx.kAlignCenter)
         end
      end
   end

   --- DRAW MASK ---
   gfx.setColor(gfx.kColorBlack)
   gfx.fillPolygon(maskPolygon)

   gfx.setColor(gfx.kColorWhite)
   gfx.drawPolygon(maskPolygon)

   --- DRAW TIMER ---
   local elapsed = pd.getElapsedTime()
   local ratio = math.min(math.max((elapsed * 1000) / timerDuration, 0), 1)
   gfx.setColor(gfx.kColorWhite)
   gfx.fillRect(0, 0, 200, 20)

   gfx.setColor(gfx.kColorBlack)
   gfx.fillRect(52, 2, 146 * (1 - ratio), 16)
   gfx.drawRect(52, 2, 146, 16)

   --- DRAW SCORE ---
   gfx.setColor(gfx.kColorBlack)
   gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
   local scoreText = ""
   if score > 0 then scoreText = "+" end
   scoreText = scoreText .. tostring(score)
   gfx.drawTextInRect("*" .. scoreText .. "*", 2, 2, 48, 20, nil, nil, kTextAlignment.center)

   --- DEBUG ---
   -- Uncomment this to show fps in the top left corner.
   -- gfx.drawText(tostring(pd.getFPS()), 4, 4)
end
