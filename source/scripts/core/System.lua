---@class System : _Object
System = class("System").extends() or System

function System:init()
   System.super.init(self)
end

function System:load()
end

function System:unload()
end

function System:preUpdate()
end

function System:update()
end

function System:render()
end
