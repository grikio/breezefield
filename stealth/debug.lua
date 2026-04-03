local vision = require((...):gsub('debug', '') .. 'vision')

local debug = {}
debug.__index = debug

function debug.new()
   return setmetatable({
      enabled = false,
      rays = {},
   }, debug)
end

function debug:toggle()
   self.enabled = not self.enabled
end

function debug:recordRay(fromX, fromY, toX, toY, clear, hit)
   self.rays[#self.rays + 1] = {
      fromX = fromX,
      fromY = fromY,
      toX = toX,
      toY = toY,
      clear = clear,
      hit = hit,
   }
end

function debug:clearFrame()
   self.rays = {}
end

function debug:draw(world, guards, player)
   if not self.enabled then
      return
   end

   world:draw(0.9, true)

   for _, guard in ipairs(guards) do
      local gx, gy = guard.body:getX(), guard.body:getY()
      local cfg = guard.config

      love.graphics.setColor(1, 0.8, 0.1, 0.35)
      love.graphics.circle('line', gx, gy, cfg.proximity_radius)

      love.graphics.setColor(0.3, 0.8, 1, 0.35)
      love.graphics.circle('line', gx, gy, cfg.vision_distance)

      local visible, _, hit = vision.canSee(world, guard.body, player, cfg)
      local px, py = player:getX(), player:getY()
      self:recordRay(gx, gy, px, py, visible, hit)
   end

   for _, ray in ipairs(self.rays) do
      if ray.clear then
         love.graphics.setColor(0, 1, 0, 1)
         love.graphics.line(ray.fromX, ray.fromY, ray.toX, ray.toY)
      else
         love.graphics.setColor(1, 0, 0, 1)
         local hx = ray.hit and ray.hit.x or ray.toX
         local hy = ray.hit and ray.hit.y or ray.toY
         love.graphics.line(ray.fromX, ray.fromY, hx, hy)
      end
   end

   self:clearFrame()
   love.graphics.setColor(1, 1, 1, 1)
end

return debug
