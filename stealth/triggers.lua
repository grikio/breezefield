local Triggers = {}

function Triggers.newZone(world, opts)
   return world:createTriggerZone(opts)
end

return Triggers
