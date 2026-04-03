local layers = require("stealth.collision_layers")
local Visibility = require("stealth.visibility")

local Perception = {}
Perception.__index = Perception

function Perception.new(world, guard_body, target, cfg)
   local sensor = world:createCollider({
      shape = "circle",
      args = {guard_body:getX(), guard_body:getY(), cfg.proximity_radius},
      body_type = "kinematic",
      sensor = true,
      kind = "proximity_sensor",
      tag = "proximity_sensor",
      category = layers.proximity_sensor,
      mask = {layers.wall, layers.guard, layers.interactable, layers.trigger},
      debug_color = {0.6, 0.7, 1.0, 0.25},
   })

   local state = {
      world = world,
      guard = guard_body,
      target = target,
      sensor = sensor,
      cfg = cfg,
      target_in_proximity = false,
      suspicion = 0,
      alert = "idle",
      last_known_position = nil,
      visible = false,
      lose_sight_timer = 0,
      vision_reason = "none",
      vision_dir = {x = 1, y = 0},
   }
   setmetatable(state, Perception)

   function sensor:enter(other)
      if other == target then
         state.target_in_proximity = true
      end
   end

   function sensor:exit(other)
      if other == target then
         state.target_in_proximity = false
      end
   end

   return state
end

function Perception:setFacing(x, y)
   local len = math.sqrt(x * x + y * y)
   if len > 0 then
      self.vision_dir.x = x / len
      self.vision_dir.y = y / len
   end
end

function Perception:update(dt)
   self.sensor:setPosition(self.guard:getPosition())

   self.visible, self.vision_reason = Visibility.canSeeTarget(self.world, self.guard, self.target, {
      distance = self.cfg.vision_distance,
      direction = self.vision_dir,
      half_angle = self.cfg.vision_angle * 0.5,
   })

   if self.target_in_proximity and self.visible then
      self.suspicion = math.min(self.cfg.alert_threshold, self.suspicion + (self.cfg.detection_rate * dt))
      self.lose_sight_timer = 0
      self.last_known_position = {self.target:getPosition()}
   else
      self.suspicion = math.max(0, self.suspicion - (self.cfg.decay_rate * dt))
      self.lose_sight_timer = self.lose_sight_timer + dt
   end

   if self.suspicion >= self.cfg.alert_threshold then
      self.alert = "alerted"
   elseif self.suspicion > 0 then
      self.alert = "suspicious"
   elseif self.last_known_position ~= nil then
      self.alert = "lost_target"
   else
      self.alert = "idle"
   end
end

return Perception
