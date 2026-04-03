local collision = require((...):gsub('triggers', '') .. 'collision')

local triggers = {}
triggers.__index = triggers

function triggers.new()
   return setmetatable({
      active = {},
      events = {},
   }, triggers)
end

function triggers:attach(triggerCollider)
   self.active[triggerCollider] = self.active[triggerCollider] or {}

   function triggerCollider:enter(other)
      if collision.getCategory(other) == collision.CATEGORY.PLAYER then
         self._trigger.active[self][other] = true
         table.insert(self._trigger.events, {type = 'enter', trigger = self, target = other})
      end
   end

   function triggerCollider:exit(other)
      if collision.getCategory(other) == collision.CATEGORY.PLAYER then
         self._trigger.active[self][other] = nil
         table.insert(self._trigger.events, {type = 'exit', trigger = self, target = other})
      end
   end

   triggerCollider._trigger = self
end

function triggers:update()
   for trigger, occupants in pairs(self.active) do
      for target, _ in pairs(occupants) do
         table.insert(self.events, {type = 'stay', trigger = trigger, target = target})
      end
   end
end

function triggers:drainEvents()
   local ev = self.events
   self.events = {}
   return ev
end

return triggers
