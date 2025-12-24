---@class StringBuilder : _Object
StringBuilder = class("StringBuilder").extends() or StringBuilder

function StringBuilder:init()
   StringBuilder.super.init(self)
   self.lines = {}
end

---Clears the string builder.
function StringBuilder:clear()
   self.lines = {}
end

---Append to last line.
---@param format string
---@param ... any
function StringBuilder:append(format, ...)
   self.lines[#self.lines] = self.lines[#self.lines] .. string.format(format, ...)
end

---Append as a new line.
---@param format string
---@param ... any
function StringBuilder:appendLine(format, ...)
   table.insert(self.lines, string.format(format, ...))
end

---Append an empty new line.
function StringBuilder:appendNewLine()
   table.insert(self.lines, "")
end

function StringBuilder:__tostring()
   return table.concat(self.lines, "\n")
end
