---@class Entity : _Object
---@field id integer
---@field version integer
---@field alive boolean
---@overload fun(id: integer): Entity
Entity = class("Entity").extends() or Entity

function Entity:init(id)
   Entity.super.init(self)
   self.id = id
   self.version = 0
   self.alive = false
end

function Entity:equals(other)
   return other.id == self.id and other.version == self.version and other.alive == self.alive
end

function Entity:__tostring()
   local status = self.alive and "alive" or "dead"
   return string.format("Entity #%q [%s|v%q]", self.id, status, self.version)
end

return Entity
