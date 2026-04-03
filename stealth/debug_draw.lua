local DebugDraw = {}
DebugDraw.__index = DebugDraw

function DebugDraw.new()
   return setmetatable({enabled = false}, DebugDraw)
end

function DebugDraw:toggle()
   self.enabled = not self.enabled
end

function DebugDraw:drawWorld(world)
   if not self.enabled then
      return
   end

   world:draw(1, true)

   for _, col in ipairs(world.entities) do
      if col.debug_color then
         love.graphics.setColor(col.debug_color)
         col:__draw__()
      end
   end
   love.graphics.setColor(1, 1, 1, 1)
end

function DebugDraw:drawGuardVision(guard, perception)
   if not self.enabled then
      return
   end

   local gx, gy = guard:getPosition()
   local dir = perception.vision_dir
   local angle = math.atan2(dir.y, dir.x)
   local half = perception.cfg.vision_angle * 0.5
   local radius = perception.cfg.vision_distance

   local clear = perception.visible and {0.3, 1, 0.3, 0.6} or {1, 0.4, 0.2, 0.6}
   love.graphics.setColor(clear)
   love.graphics.arc("line", "open", gx, gy, radius, angle - half, angle + half, 18)

   if perception.last_known_position then
      love.graphics.setColor(1, 1, 0.2, 0.7)
      love.graphics.circle("line", perception.last_known_position[1], perception.last_known_position[2], 8)
   end

   if perception.target then
      local tx, ty = perception.target:getPosition()
      love.graphics.line(gx, gy, tx, ty)
   end

   love.graphics.setColor(1, 1, 1, 1)
end

return DebugDraw
