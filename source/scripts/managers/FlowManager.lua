---@class FlowManager
---@field state table
FlowManager = {}

function FlowManager:init()
   self.state = nil
end

function FlowManager:update()
   if self.state then self.state:update() end
end

function FlowManager:setState(newState)
   if self.state then self.state:leave() end
   self.state = newState
   if self.state then self.state:enter() end
end
