local Visibility = {}

local function normalize(x, y)
   local len = math.sqrt(x * x + y * y)
   if len == 0 then
      return 0, 0, 0
   end
   return x / len, y / len, len
end

local function in_cone(forward_x, forward_y, to_x, to_y, half_angle)
   local nx, ny = normalize(to_x, to_y)
   local dot = (forward_x * nx + forward_y * ny)
   return dot >= math.cos(half_angle)
end

function Visibility.canSeeTarget(world, observer, target, opts)
   opts = opts or {}
   local ox, oy = observer:getPosition()
   local tx, ty = target:getPosition()
   local dx, dy, dist = normalize(tx - ox, ty - oy)
   local max_dist = opts.distance or math.huge

   if dist > max_dist then
      return false, "out_of_range"
   end

   if opts.direction and opts.half_angle then
      if not in_cone(opts.direction.x, opts.direction.y, tx - ox, ty - oy, opts.half_angle) then
         return false, "outside_cone"
      end
   end

   local blocked = false
   world:raycast(ox, oy, tx, ty, function(fixture, _, _, fraction)
      local hit = fixture:getUserData()
      if hit == observer then
         return -1
      end
      if hit == target then
         return fraction
      end
      if hit and (hit.kind == "wall" or hit.blocks_vision) then
         blocked = true
         return 0
      end
      return -1
   end)

   if blocked then
      return false, "blocked"
   end

   return true, "clear"
end

return Visibility
