local collision = require((...):gsub('proximity', '') .. 'collision')

local proximity = {}
proximity.__index = proximity

function proximity.new()
   return setmetatable({
      guards = {},
      events = {},
   }, proximity)
end

function proximity:attachGuardSensor(guard, sensor)
   self.guards[sensor] = guard

   function sensor:enter(other)
      if collision.getCategory(other) == collision.CATEGORY.PLAYER then
         table.insert(self._prox.events, {type = 'enter', guard = self._prox.guards[self], target = other})
      end
   end

   function sensor:exit(other)
      if collision.getCategory(other) == collision.CATEGORY.PLAYER then
         table.insert(self._prox.events, {type = 'exit', guard = self._prox.guards[self], target = other})
      end
   end

   sensor._prox = self
end

function proximity:drainEvents()
   local ev = self.events
   self.events = {}
   return ev
end

return proximity
