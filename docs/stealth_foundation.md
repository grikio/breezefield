# Stealth Foundation on Top of Breezefield

This package adds gameplay systems *around* Breezefield for topdown stealth games.

## Modules

- `stealth.world`: world wrapper with collision layers, tagged colliders, trigger routing.
- `stealth.movement`: predictable arcade-style player movement.
- `stealth.perception`: guard proximity + suspicion + vision checks.
- `stealth.visibility`: reusable line-of-sight and vision cone checks via raycast.
- `stealth.triggers`: helper for gameplay area zones.
- `stealth.debug_draw`: debug visualization for colliders, ranges, and LOS lines.
- `stealth.config`: tuning values.

## Create a Guard

```lua
local guard = world:createCollider({
  shape = "circle",
  args = {300, 120, cfg.guard.radius},
  body_type = "kinematic",
  kind = "guard",
  tag = "guard",
  category = stealth.layers.guard,
})

local perception = stealth.Perception.new(world, guard, player, cfg.guard)
perception:setFacing(1, 0)
```

Call `perception:update(dt)` every frame.

## Create a Trigger Zone

```lua
stealth.Triggers.newZone(world, {
  shape = "rectangle",
  args = {500, 100, 120, 80},
  tag = "restricted",
  on_enter = function(zone, actor) end,
  on_stay = function(zone, actor, dt) end,
  on_exit = function(zone, actor) end,
})
```

Zones are sensors, so they do not push bodies.

## Configure Sensors and Vision

Tune `stealth/config.lua`:

- `guard.proximity_radius`
- `guard.vision_distance`
- `guard.vision_angle`
- `guard.detection_rate`
- `guard.decay_rate`
- `guard.alert_threshold`

The guard only sees a target when:

1. target is in range,
2. target is inside FOV cone,
3. raycast to target is not blocked by walls.

## Debug Mode

Use `stealth.DebugDraw` and toggle at runtime:

```lua
debug = stealth.DebugDraw.new()
debug:toggle() -- e.g., F1
```

When enabled, it draws collider outlines, sensor areas, vision arcs, LOS lines, and last known target position.

## Sample Scene

See `test/stealth_demo/main.lua` for:

- one player,
- wall layout,
- two guards,
- one restricted area,
- one alarm trigger.
