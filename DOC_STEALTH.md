# Breezefield Stealth Extensions

This repository now includes a lightweight stealth gameplay foundation on top of Breezefield under `stealth/`.

## Modules

- `stealth/world.lua`: world wrapper and entity factories (player, guard, wall, trigger, interactable).
- `stealth/collision.lua`: category/tag constants and helper functions.
- `stealth/movement.lua`: topdown movement tuning (zero gravity, fixed rotation, damping).
- `stealth/proximity.lua`: enter/exit events for guard proximity sensors.
- `stealth/triggers.lua`: enter/stay/exit events for trigger zones.
- `stealth/vision.lua`: range, cone, and raycast-based line-of-sight checks.
- `stealth/debug.lua`: toggleable debug rendering for ranges and LOS rays.
- `stealth/config.lua`: data-driven gameplay defaults.

## How to create a guard

```lua
local stealth = require('breezefield').stealth
local sworld = stealth.world.new()
local guard = sworld:createGuard(320, 140, {
  collider = {width = 18, height = 18},
  proximity_radius = 96,
  vision_distance = 200,
  vision_angle = math.rad(70),
  facing_x = 1,
  facing_y = 0,
})
```

Guard objects include:

- `guard.body` (solid collision body)
- `guard.proximity` (sensor fixture)
- `guard.config`

## How to create a trigger zone

```lua
local restricted = sworld:createTrigger(200, 220, 160, 100, 'restricted')
```

Then attach to the trigger manager:

```lua
local triggerSystem = stealth.triggers.new()
triggerSystem:attach(restricted)
```

Call `triggerSystem:update()` each frame and read events from `triggerSystem:drainEvents()`.

## How to configure sensors

- Proximity sensors are created via `createGuard` as non-solid circle sensors.
- Trigger sensors are created via `createTrigger` as non-solid rectangle sensors.
- Use `stealth.proximity` and `stealth.triggers` to subscribe to events.

```lua
local prox = stealth.proximity.new()
prox:attachGuardSensor(guard.body, guard.proximity)
for _, event in ipairs(prox:drainEvents()) do
  -- event.type is "enter" or "exit"
end
```

## How to use debug mode

```lua
local dbg = stealth.debug.new()

dbg:toggle() -- enable/disable

if dbg.enabled then
  dbg:draw(sworld.world, guards, player)
end
```

Debug mode visualizes:

- collider outlines
- proximity and vision ranges
- line-of-sight rays (green clear / red blocked)

## Sample scene

Run the sample in `test/stealth_sample/main.lua`:

- one player
- wall layout
- two guards
- one restricted area
- one alarm trigger

Controls:

- Arrow keys: move
- Tab: toggle debug visualization
