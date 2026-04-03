local movement = {}

local function normalize(x, y)
   local len = math.sqrt(x * x + y * y)
   if len == 0 then
      return 0, 0
   end
   return x / len, y / len
end

function movement.makeTopdownBody(collider, damping)
   collider:setGravityScale(0)
   collider:setFixedRotation(true)
   collider:setLinearDamping(damping or 10)
   collider:setAngularDamping(20)
   collider:setRestitution(0)
   collider:setFriction(0)
end

function movement.applyInput(collider, ix, iy, speed)
   local nx, ny = normalize(ix, iy)
   collider:setLinearVelocity(nx * speed, ny * speed)
end

return movement
