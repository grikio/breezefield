local bf = require("breezefield")
local layers = require("stealth.collision_layers")

local StealthWorld = {}
StealthWorld.__index = StealthWorld

local function key_for(a, b)
   return tostring(a) .. "::" .. tostring(b)
end

local function set_filter(collider, category, masks)
   collider:setCategory(category)
   collider:setMask(unpack(masks or {}))
end

function StealthWorld.new(opts)
   opts = opts or {}
   local world = {
      physics = bf.newWorld(0, 0, true),
      entities = {},
      triggers = {},
      trigger_pairs = {},
      collision_layers = layers,
   }
   setmetatable(world, StealthWorld)
   return world
end

function StealthWorld:createCollider(def)
   local collider = self.physics:newCollider(def.shape, def.args)
   collider:setType(def.body_type or "dynamic")
   collider:setFixedRotation(def.fixed_rotation ~= false)
   collider:setLinearDamping(def.linear_damping or 0)
   collider:setRestitution(0)
   collider:setFriction(0)
   collider:setSensor(def.sensor == true)
   collider.tag = def.tag
   collider.kind = def.kind
   collider.debug_color = def.debug_color

   if def.category then
      set_filter(collider, def.category, def.mask)
   end

   table.insert(self.entities, collider)
   return collider
end

function StealthWorld:createWall(x, y, w, h)
   return self:createCollider({
      shape = "rectangle",
      args = {x, y, w, h},
      body_type = "static",
      kind = "wall",
      tag = "wall",
      category = layers.wall,
      mask = {layers.proximity_sensor, layers.vision_sensor, layers.trigger},
      debug_color = {0.65, 0.65, 0.7, 1},
   })
end

function StealthWorld:createTriggerZone(opts)
   local trigger = self:createCollider({
      shape = opts.shape or "rectangle",
      args = opts.args,
      body_type = "static",
      sensor = true,
      kind = "trigger",
      tag = opts.tag or "trigger",
      category = layers.trigger,
      mask = {layers.wall},
      debug_color = opts.debug_color or {0.8, 0.2, 0.2, 0.35},
   })
   trigger.on_enter = opts.on_enter
   trigger.on_stay = opts.on_stay
   trigger.on_exit = opts.on_exit
   self.triggers[trigger] = {actors = {}}
   return trigger
end

function StealthWorld:_is_sensor_pair(a, b)
   return a:isSensor() or b:isSensor()
end

function StealthWorld:_process_pair(event, self_col, other_col, contact)
   if self_col and self_col[event] then
      self_col[event](self_col, other_col, contact)
   end

   if self_col and self_col.kind == "trigger" and other_col then
      local pair_key = key_for(self_col, other_col)
      local state = self.triggers[self_col]
      if state then
         if event == "enter" then
            state.actors[other_col] = true
            self.trigger_pairs[pair_key] = {trigger = self_col, actor = other_col}
            if self_col.on_enter then
               self_col.on_enter(self_col, other_col)
            end
         elseif event == "exit" then
            state.actors[other_col] = nil
            self.trigger_pairs[pair_key] = nil
            if self_col.on_exit then
               self_col.on_exit(self_col, other_col)
            end
         end
      end
   end
end

function StealthWorld:_on_collision(event, a, b, contact)
   local col_a = a:getUserData()
   local col_b = b:getUserData()
   if not col_a or not col_b then
      return
   end
   self:_process_pair(event, col_a, col_b, contact)
   self:_process_pair(event, col_b, col_a, contact)
end

function StealthWorld:update(dt)
   self.physics:update(dt)

   for _, pair in pairs(self.trigger_pairs) do
      local trigger = pair.trigger
      local actor = pair.actor
      if trigger and actor and trigger.on_stay then
         trigger.on_stay(trigger, actor, dt)
      end
   end
end

function StealthWorld:setCallbacks()
   self.physics:setCallbacks(
      function(a, b, c) self:_on_collision("enter", a, b, c) end,
      function(a, b, c) self:_on_collision("exit", a, b, c) end,
      function(a, b, c) self:_on_collision("preSolve", a, b, c) end,
      function(a, b, c, n, t) self:_on_collision("postSolve", a, b, c, n, t) end
   )
end

function StealthWorld:draw(alpha, draw_shapes)
   self.physics:draw(alpha, draw_shapes)
end

function StealthWorld:raycast(x1, y1, x2, y2, callback)
   self.physics:rayCast(x1, y1, x2, y2, callback)
end

return StealthWorld
