local Movement = {}
Movement.__index = Movement

function Movement.new(collider, speed)
   return setmetatable({collider = collider, speed = speed}, Movement)
end

function Movement:update(input_x, input_y)
   local mag = math.sqrt(input_x * input_x + input_y * input_y)
   if mag > 0 then
      input_x, input_y = input_x / mag, input_y / mag
   end
   self.collider:setLinearVelocity(input_x * self.speed, input_y * self.speed)
end

return Movement
