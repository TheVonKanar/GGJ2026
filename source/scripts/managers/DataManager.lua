---@class DataManager
DataManager = {
   cache = {}
}

local pd <const> = playdate

function DataManager:init()
end

function DataManager:update()
end

---@param path string
---@return table
function DataManager:getData(path)
   local data = self.cache[path]
   if data then
      return data
   end

   data = pd.datastore.read(path)

   if not data then
      error(string.format("Could not find data at path %s1.", path))
      return {}
   end

   self.cache[path] = data
   return data
end
