local collision = require((...):gsub('vision', '') .. 'collision')

local vision = {}

local function dot(ax, ay, bx, by)
   return ax * bx + ay * by
end

local function length(x, y)
   return math.sqrt(x * x + y * y)
end

local function normalize(x, y)
   local len = length(x, y)
   if len == 0 then
      return 0, 0
   end
   return x / len, y / len
end

function vision.inRange(observer, target, maxDistance)
   local dx = target:getX() - observer:getX()
   local dy = target:getY() - observer:getY()
   return (dx * dx + dy * dy) <= (maxDistance * maxDistance), dx, dy
end

function vision.inCone(guard, dx, dy, fov)
   if not fov then
      return true
   end

   local fx, fy = guard.facing_x or 1, guard.facing_y or 0
   fx, fy = normalize(fx, fy)
   local tx, ty = normalize(dx, dy)

   local alignment = dot(fx, fy, tx, ty)
   return alignment >= math.cos(fov * 0.5)
end

function vision.hasLineOfSight(world, observer, target)
   local ox, oy = observer:getX(), observer:getY()
   local tx, ty = target:getX(), target:getY()

   local blocked = false
   local hitPoint = nil

   world:rayCast(ox, oy, tx, ty, function(fixture, x, y)
      local collider = fixture:getUserData()
      if collider == observer or collider == target then
         return -1
      end

      if collision.getCategory(collider) == collision.CATEGORY.WALL then
         blocked = true
         hitPoint = {x = x, y = y}
         return 0
      end

      return -1
   end)

   return not blocked, hitPoint
end

function vision.canSee(world, guard, target, config)
   local inRange, dx, dy = vision.inRange(guard, target, config.vision_distance)
   if not inRange then
      return false, 'out_of_range'
   end

   if config.vision_angle and not vision.inCone(guard, dx, dy, config.vision_angle) then
      return false, 'outside_cone'
   end

   local clear, hit = vision.hasLineOfSight(world, guard, target)
   if not clear then
      return false, 'blocked', hit
   end

   return true, 'visible'
end

return vision
