local config = {
   player = {
      collider = {shape = 'rectangle', width = 18, height = 18},
      speed = 150,
      damping = 10,
   },
   guard = {
      collider = {shape = 'rectangle', width = 18, height = 18},
      proximity_radius = 96,
      vision_distance = 180,
      vision_angle = math.rad(90),
      facing_x = 1,
      facing_y = 0,
      detection_time = 0.75,
      forget_time = 1.5,
   },
   alert = {
      suspicious_time = 0.75,
      alerted_time = 1.5,
   },
}

return config
