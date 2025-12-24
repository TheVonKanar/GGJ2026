---@class World
---@field isLoaded boolean
---@field entities Entity[]
---@field archetypes Archetype[]
---@field systems System[]
---@field tags string[]
World = {
   tags = {}
}

function World:load(systems)
   self.systems = systems
   self.entities = {}
   self.archetypes = {}

   for _, system in ipairs(self.systems) do
      system:load()
   end

   self.isLoaded = true
end

function World:unload()
   self.isLoaded = false

   for _, system in ipairs(self.systems) do
      system:unload()
   end

   for _, archetype in ipairs(self.archetypes) do
      archetype:clearEntities()
   end

   self.archetypes = nil
   self.entities = nil
   self.systems = nil
end

function World:update()
   if not self.isLoaded then
      return
   end

   for _, system in ipairs(self.systems) do
      system:preUpdate()
   end

   for _, system in ipairs(self.systems) do
      system:update()
   end

   for _, system in ipairs(self.systems) do
      system:render()
   end
end

---Register a new tag, and return its index.
---@param tagName string
---@return integer
function World:registerTag(tagName)
   table.insert(self.tags, tagName)
   return #self.tags
end

---Return the id of the given tag from its name.
---@param tagName string
---@return integer
function World:getTagId(tagName)
   return table.indexOfElement(self.tags, tagName) or -1
end

---@param components Component[]
---@return integer
function World:createEntity(components)
   -- Craft the corresponding archetype ID based on the given list of components.
   local componentNames = {}
   for _, component in ipairs(components) do
      table.insert(componentNames, component.className)
   end

   -- Get or create the archetype.
   local archetypeIndex = 0
   for i, a in ipairs(self.archetypes) do
      if a:hasComponents(componentNames, true) then
         archetypeIndex = i
      end
   end

   if archetypeIndex == 0 then
      table.insert(self.archetypes, Archetype(componentNames))
      archetypeIndex = #self.archetypes
   end

   -- Get a recyclable entity or create a new one if needed.
   ---@type Entity
   local entity = nil

   for _, value in ipairs(self.entities) do
      if value.alive == false then
         entity = value
         break
      end
   end

   if entity == nil then
      entity = Entity(#self.entities + 1)
      table.insert(self.entities, entity)
   end

   entity.alive = true

   -- Add the entity and its components to the archetype.
   self.archetypes[archetypeIndex]:addEntity(entity.id, components)

   -- Return the entity id.
   return entity.id
end

function World:destroyEntity(entityId)
   local archetype = self:getEntityArchetype(entityId)
   if not archetype then
      return
   end

   archetype:removeEntity(entityId)

   local entity = self.entities[entityId]
   entity.alive = false
   entity.version += 1
end

function World:isEntityAlive(entityId)
   return entityId > 0 and entityId <= #self.entities and self.entities[entityId].alive
end

---Gets the archetype associated with the given entity ID.
---@param entityId integer
---@return Archetype?, integer
function World:getEntityArchetype(entityId)
   if entityId < 1 or entityId > #self.entities then
      return nil, -1
   end

   if not self.entities[entityId].alive then
      return nil, -1
   end

   for _, a in ipairs(self.archetypes) do
      for i, id in ipairs(a.entityIds) do
         if id == entityId then
            return a, i
         end
      end
   end

   error(string.format("Could not find Archetype for entity #%q", entityId))
   return nil, -1
end

---Search through all entities that match the given componentNames filter
---and returns all their entity IDs and relevant components.
---@param componentNames string[]: list of the names of the components you want. Use typeof(MyComponentClass).
---@return integer[], ComponentSet[]: entityIds table, component sets table
function World:getComponentSets(componentNames)
   local ids = {}
   local sets = {}

   for _, a in ipairs(self.archetypes) do
      if a:hasComponents(componentNames, false) then
         for i, id in ipairs(a.entityIds) do
            table.insert(ids, id)

            local set = ComponentSet()
            for _, name in ipairs(componentNames) do
               set[name] = a.components[name][i]
            end
            table.insert(sets, set)
         end
      end
   end

   return ids, sets
end

---Get a component set of the given entityID that matches the given componentNames filter.
---@param entityId integer
---@param componentNames string[]
---@return ComponentSet?
function World:getComponentSet(entityId, componentNames)
   local archetype, index = self:getEntityArchetype(entityId)
   if not archetype then
      return nil
   end

   local set = ComponentSet()
   for _, name in ipairs(componentNames) do
      set[name] = archetype.components[name][index]
   end

   return set
end

---Get a single component of the given entity ID.
---@param entityId integer
---@param componentName string
---@return any
function World:getComponent(entityId, componentName)
   local archetype, index = self:getEntityArchetype(entityId)
   if not archetype then
      return nil
   end

   if not archetype.components[componentName] then
      error(string.format("Archetype %q doesn't have component %q", archetype.name, componentName))
      return nil
   end

   return archetype.components[componentName][index]
end

function World:__tostring()
   ---@type StringBuilder
   local sb = StringBuilder()

   sb:appendLine("---------- WORLD ----------")
   for _, a in pairs(self.archetypes) do
      sb:appendLine(a:__tostring())
   end
   sb:appendLine("---------------------------")

   return sb:__tostring()
end

setmetatable(World, {
   __tostring = World.__tostring
})
