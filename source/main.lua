---- IMPORTS ----

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

---- DATA ----

import "masks"
import "menu"

local letters = { "E", "G", "G" }

---- LOCALS ----

local pd <const> = playdate
local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

local crankMul = 0.2

local rawGridY = 0
local gridY = 0
local rows = Menu
local cellWidth = 20
local cellHeight = 20
local maxRows = 16

---@class _Polygon
local maskPolygon
local mask
local maskX = cellWidth * 5
local maskY = cellHeight * 4
local maskIndex = 6

local sample = pd.sound.sampleplayer.new("egg.wav")

local goLeftTimer
local goRightTimer
local goUpTimer
local goDownTimer

---- FUNCTIONS ----

local function createRow()
   local row = { cells = {} }
   for i = 1, 10 do
      table.insert(row.cells, i, letters[math.random(#letters)])
   end
   return row
end

local function pickMask(i)
   mask = Masks[i]

   local points = {}
   for _, p in ipairs(mask.polygon) do
      table.insert(points, geo.point.new(
         maskX + p[1] * cellWidth,
         maskY + p[2] * cellHeight))
   end
   maskPolygon = geo.polygon.new(table.unpack(points))
end

local function validate()
   for y, row in ipairs(rows) do
      for x = 1, #row.cells do
         local point = geo.point.new(
            (x - 1) * cellWidth,
            gridY + ((y - 1) * cellHeight) + 2
         ):offsetBy(cellWidth / 2, cellHeight / 2)

         if maskPolygon:containsPoint(point) then
            rows[y].cells[x] = " "
         end
      end
   end

   local new = maskIndex
   while new == maskIndex do
      new = math.random(#Masks)
   end
   maskIndex = new
   pickMask(maskIndex)
   sample:play()
end

---- INIT ----

math.randomseed(playdate.getSecondsSinceEpoch())
pd.display.setScale(2)
gfx.setLineWidth(1)
gfx.setBackgroundColor(gfx.kColorBlack)

for i = 1, maxRows do
   table.insert(rows, createRow())
end

table.insert(rows, { cells = { " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", }, isMenu = true })
table.insert(rows, { cells = { " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", }, isMenu = true })

pickMask(maskIndex)

---- UPDATE LOOP ----

function pd.update()
   gfx.clear()
   gfx.sprite.update()
   pd.timer.updateTimers()

   --- INPUTS ---
   -- Crank (grid scrolling)
   local change, acceleratedChange = playdate.getCrankChange()
   rawGridY = rawGridY - change * crankMul
   rawGridY = math.min(rawGridY, 0)
   rawGridY = math.max(rawGridY, (#rows - 6 - 2) * -cellHeight)
   local oldGridY = gridY
   gridY = math.floor((rawGridY / cellHeight) + 0.5) * cellHeight

   if goLeftTimer and not pd.buttonIsPressed(pd.kButtonLeft) then goLeftTimer:pause() end
   if goRightTimer and not pd.buttonIsPressed(pd.kButtonRight) then goRightTimer:pause() end
   if goUpTimer and not pd.buttonIsPressed(pd.kButtonUp) then goUpTimer:pause() end
   if goDownTimer and not pd.buttonIsPressed(pd.kButtonDown) then goDownTimer:pause() end

   --- DRAW GRID ---
   local score = 0
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
            local isSolved = false

            if text == "E" and
                x < 9 and
                row.cells[x + 1] == "G" and
                row.cells[x + 2] == "G" and
                (x == 1 or row.cells[x - 1] == " ") and
                (x == 8 or row.cells[x + 3] == " ")
            then
               isSolved = true
               score = score + 1
            end

            if text == "G" and
                x > 1 and
                x < 10 and
                row.cells[x - 1] == "E" and
                row.cells[x + 1] == "G" and
                (x == 2 or row.cells[x - 2] == " ") and
                (x == 9 or row.cells[x + 2] == " ")
            then
               isSolved = true
               score = score + 1
            end

            if text == "G" and
                x > 2 and
                row.cells[x - 1] == "G" and
                row.cells[x - 2] == "E" and
                (x == 3 or row.cells[x - 3] == " ") and
                (x == 10 or row.cells[x + 1] == " ")
            then
               isSolved = true
               score = score + 1
            end

            if text == "E" and
                y > 1 and y < #rows - 3 and
                rows[y - 1].cells[x] == " " and
                rows[y + 1].cells[x] == "G" and
                rows[y + 2].cells[x] == "G" and
                rows[y + 3].cells[x] == " "
            then
               isSolved = true
               score = score + 1
            end

            if text == "G" and
                y > 2 and y < #rows - 2 and
                rows[y - 2].cells[x] == " " and
                rows[y - 1].cells[x] == "E" and
                rows[y + 1].cells[x] == "G" and
                rows[y + 2].cells[x] == " "
            then
               isSolved = true
               score = score + 1
            end

            if text == "G" and
                y > 3 and y < #rows - 1 and
                rows[y - 3].cells[x] == " " and
                rows[y - 2].cells[x] == "E" and
                rows[y - 1].cells[x] == "G" and
                rows[y + 1].cells[x] == " "
            then
               isSolved = true
               score = score + 1
            end

            if row.isMenu or isSolved then
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

   -- --- DRAW SCORE ---
   gfx.setColor(gfx.kColorWhite)
   gfx.fillRect(0, 0, 40, 20)
   gfx.setColor(gfx.kColorBlack)
   gfx.fillCircleAtPoint(2, 2, 1)
   gfx.fillCircleAtPoint(38, 2, 1)
   gfx.fillCircleAtPoint(2, 18, 1)
   gfx.fillCircleAtPoint(38, 18, 1)
   gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
   gfx.drawTextInRect("*" .. tostring(math.ceil(score / 3)) .. "*", 2, 2, 36, 20, nil, nil, kTextAlignment.center)
end

local function goLeft()
   local maskBounds = maskPolygon:getBoundsRect()
   if maskBounds.left > 0 then
      maskPolygon:translate(-cellWidth, 0)
      maskX = maskX - cellWidth
   end
end

local function goRight()
   local maskBounds = maskPolygon:getBoundsRect()
   if maskBounds.right < 200 then
      maskPolygon:translate(cellWidth, 0)
      maskX = maskX + cellWidth
   end
end

local function goUp()
   local maskBounds = maskPolygon:getBoundsRect()
   if maskBounds.top > 0 then
      maskPolygon:translate(0, -cellHeight)
      maskY = maskY - cellHeight
   end
end

local function goDown()
   local maskBounds = maskPolygon:getBoundsRect()
   if maskBounds.bottom < 120 then
      maskPolygon:translate(0, cellHeight)
      maskY = maskY + cellHeight
   end
end

function pd.leftButtonDown()
   goLeftTimer = pd.timer.keyRepeatTimer(goLeft)
end

function pd.leftButtonUp()
   goLeftTimer:pause()
end

function pd.rightButtonDown()
   goRightTimer = pd.timer.keyRepeatTimer(goRight)
end

function pd.rightButtonUp()
   goRightTimer:pause()
end

function pd.upButtonDown()
   goUpTimer = pd.timer.keyRepeatTimer(goUp)
end

function pd.upButtonUp()
   goUpTimer:pause()
end

function pd.downButtonDown()
   goDownTimer = pd.timer.keyRepeatTimer(goDown)
end

function pd.downButtonUp()
   goDownTimer:pause()
end

function pd.AButtonDown()
   validate()
end

function pd.BButtonDown()
   validate()
end
