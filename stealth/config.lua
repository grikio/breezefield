local config = {
   player = {
      radius = 12,
      speed = 170,
      linear_damping = 14,
   },
   guard = {
      radius = 12,
      proximity_radius = 120,
      vision_distance = 210,
      vision_angle = math.rad(70),
      detection_rate = 0.9,
      decay_rate = 0.5,
      alert_threshold = 1.0,
   },
   alert = {
      suspicious_threshold = 0.35,
      lose_sight_grace = 1.5,
   },
   debug = {
      enabled = false,
   },
}

return config
