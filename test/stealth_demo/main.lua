local stealth = require("stealth")

local cfg = stealth.config
local world
local player
local player_move
local guards = {}
local debug
local status_lines = {}

local function axis()
   local x, y = 0, 0
   if love.keyboard.isDown("a") then x = x - 1 end
   if love.keyboard.isDown("d") then x = x + 1 end
   if love.keyboard.isDown("w") then y = y - 1 end
   if love.keyboard.isDown("s") then y = y + 1 end
   return x, y
end

local function spawn_guard(x, y, facing)
   local body = world:createCollider({
      shape = "circle",
      args = {x, y, cfg.guard.radius},
      body_type = "kinematic",
      fixed_rotation = true,
      kind = "guard",
      tag = "guard",
      category = stealth.layers.guard,
      mask = {stealth.layers.proximity_sensor, stealth.layers.trigger},
      debug_color = {0.8, 0.2, 0.2, 1},
   })

   local perception = stealth.Perception.new(world, body, player, cfg.guard)
   perception:setFacing(facing.x, facing.y)

   guards[#guards + 1] = {body = body, perception = perception}
end

function love.load()
   world = stealth.World.new()
   world:setCallbacks()

   player = world:createCollider({
      shape = "circle",
      args = {80, 80, cfg.player.radius},
      fixed_rotation = true,
      linear_damping = cfg.player.linear_damping,
      kind = "player",
      tag = "player",
      category = stealth.layers.player,
      mask = {stealth.layers.proximity_sensor, stealth.layers.trigger, stealth.layers.vision_sensor},
      debug_color = {0.2, 0.95, 0.4, 1},
   })

   player_move = stealth.Movement.new(player, cfg.player.speed)

   world:createWall(220, 140, 240, 24)
   world:createWall(220, 270, 240, 24)
   world:createWall(100, 230, 24, 240)
   world:createWall(340, 230, 24, 240)

   stealth.Triggers.newZone(world, {
      shape = "rectangle",
      args = {480, 120, 130, 90},
      tag = "restricted",
      debug_color = {1, 0.6, 0.1, 0.3},
      on_enter = function(_, actor)
         if actor == player then
            status_lines[#status_lines + 1] = "Player entered restricted area"
         end
      end,
      on_exit = function(_, actor)
         if actor == player then
            status_lines[#status_lines + 1] = "Player exited restricted area"
         end
      end,
      on_stay = function(_, actor, dt)
         if actor == player and dt > 0 then
            -- hook for sustained alarm buildup
         end
      end,
   })

   stealth.Triggers.newZone(world, {
      shape = "circle",
      args = {550, 280, 70},
      tag = "alarm",
      debug_color = {1, 0.2, 0.2, 0.3},
      on_enter = function(_, actor)
         if actor == player then
            status_lines[#status_lines + 1] = "Alarm trigger touched"
         end
      end,
   })

   spawn_guard(280, 90, {x = 1, y = 0})
   spawn_guard(280, 320, {x = -1, y = 0})

   debug = stealth.DebugDraw.new()
end

function love.update(dt)
   player_move:update(axis())
   world:update(dt)

   for _, g in ipairs(guards) do
      g.perception:update(dt)
   end

   while #status_lines > 6 do
      table.remove(status_lines, 1)
   end
end

function love.keypressed(key)
   if key == "f1" then
      debug:toggle()
   end
end

function love.draw()
   love.graphics.clear(0.08, 0.08, 0.1)
   debug:drawWorld(world)

   for _, g in ipairs(guards) do
      debug:drawGuardVision(g.body, g.perception)
   end

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.print("WASD to move, F1 debug", 12, 10)
   local y = 28
   for _, guard in ipairs(guards) do
      local gx, gy = guard.body:getPosition()
      local p = guard.perception
      local line = string.format("Guard(%.0f,%.0f) state=%s suspicion=%.2f vision=%s", gx, gy, p.alert, p.suspicion, p.vision_reason)
      love.graphics.print(line, 12, y)
      y = y + 16
   end

   for _, line in ipairs(status_lines) do
      love.graphics.print(line, 12, y)
      y = y + 16
   end
end
