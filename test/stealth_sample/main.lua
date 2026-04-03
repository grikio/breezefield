local bf = require('breezefield')
local stealth = bf.stealth

local game = {}

function love.load()
   game.world = stealth.world.new()
   game.player = game.world:createPlayer(80, 80)

   game.walls = {
      game.world:createWall(200, 120, 30, 180),
      game.world:createWall(320, 220, 200, 30),
      game.world:createWall(420, 140, 30, 200),
   }

   game.guards = {
      game.world:createGuard(280, 80),
      game.world:createGuard(520, 260, {
         collider = {width = 18, height = 18},
         proximity_radius = 80,
         vision_distance = 220,
         vision_angle = math.rad(65),
         facing_x = -1,
         facing_y = 0,
      }),
   }

   game.restrictedArea = game.world:createTrigger(120, 260, 180, 120, 'restricted')
   game.alarmArea = game.world:createTrigger(470, 80, 140, 100, 'alarm')

   game.proximity = stealth.proximity.new()
   for _, guard in ipairs(game.guards) do
      game.proximity:attachGuardSensor(guard.body, guard.proximity)
   end

   game.triggers = stealth.triggers.new()
   game.triggers:attach(game.restrictedArea)
   game.triggers:attach(game.alarmArea)

   game.debug = stealth.debug.new()
   game.messages = {}
end

local function pushMessage(text)
   table.insert(game.messages, 1, text)
   while #game.messages > 8 do
      table.remove(game.messages)
   end
end

function love.update(dt)
   local ix = (love.keyboard.isDown('right') and 1 or 0) - (love.keyboard.isDown('left') and 1 or 0)
   local iy = (love.keyboard.isDown('down') and 1 or 0) - (love.keyboard.isDown('up') and 1 or 0)
   stealth.movement.applyInput(game.player, ix, iy, game.world.config.player.speed)

   game.world:update(dt)
   game.triggers:update()

   for _, event in ipairs(game.proximity:drainEvents()) do
      pushMessage(('proximity %s by guard @ %.0f,%.0f'):format(event.type, event.guard:getX(), event.guard:getY()))
   end

   for _, event in ipairs(game.triggers:drainEvents()) do
      pushMessage(('trigger %s: %s'):format(event.type, event.trigger.trigger_name))
   end

   for _, guard in ipairs(game.guards) do
      local visible, reason = stealth.vision.canSee(game.world.world, guard.body, game.player, guard.config)
      if visible then
         pushMessage('guard sees player')
      elseif reason == 'blocked' then
         pushMessage('guard vision blocked')
      end
   end
end

function love.keypressed(key)
   if key == 'tab' then
      game.debug:toggle()
   end
end

function love.draw()
   game.world.world:draw(1, true)

   if game.debug.enabled then
      game.debug:draw(game.world.world, game.guards, game.player)
   end

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.print('Arrows: move | Tab: debug overlay', 8, 8)
   for i, message in ipairs(game.messages) do
      love.graphics.print(message, 8, 12 + i * 16)
   end
end
