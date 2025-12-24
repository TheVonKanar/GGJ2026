---@class Archetype : _Object
---@field entityIds integer[]
---@field name string
---@field complexity integer
---@field components Component[][]
---@overload fun(componentNames:string[]) : Archetype
Archetype = class("Archetype").extends() or Archetype

function Archetype:init(componentNames)
   Archetype.super.init(self)
   self.entityIds = {}
   self.name = table.concat(componentNames, "-")
   self.complexity = #componentNames
   self.components = {}
   for _, name in ipairs(componentNames) do
      self.components[name] = {}
   end
end

function Archetype:addEntity(entityId, components)
   if #components ~= self.complexity then
      error(string.format("Count mismatch in addEntity: in:%q | self:%q"))
      return
   end

   table.insert(self.entityIds, entityId)
   for _, component in ipairs(components) do
      table.insert(self.components[component.className], component)
   end
end

function Archetype:removeEntity(entityId)
   local index = table.indexOfElement(self.entityIds, entityId)
   if not index then
      return
   end

   table.remove(self.entityIds, index)
   for _, array in pairs(self.components) do
      array[index]:release()
      table.remove(array, index)
   end
end

function Archetype:clearEntities()
   for _, array in pairs(self.components) do
      for i, _ in ipairs(array) do
         array[i]:release()
      end
   end

   self.entityIds = {}
   self.components = {}
end

---Checks if the archetype contains the given entity.
---@param entityId integer
---@return boolean
function Archetype:hasEntity(entityId)
   for _, id in ipairs(self.entityIds) do
      if id == entityId then
         return true
      end
   end

   return false
end

---Checks if the archetype contains components of the given names.
---Use <b>typeof(MyComponentClass)</b> or <b>MyComponent.className</b>.
---@param componentNames string[]
---@param isStrict boolean
---@return boolean
function Archetype:hasComponents(componentNames, isStrict)
   if isStrict and #componentNames ~= self.complexity then return false end

   for _, name in ipairs(componentNames) do
      if self.components[name] == nil then
         return false
      end
   end

   return true
end

function Archetype:__tostring()
   return string.format("[%q] => %q entities", self.name, #self.entityIds)
end
