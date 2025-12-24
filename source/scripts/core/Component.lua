---@class Component : _Object
Component = class("Component").extends() or Component

function Component:init()
   Component.super.init(self)
end

function Component:release()
end
