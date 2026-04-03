local bf = require((...):gsub('stealth.world', ''))
local collision = require((...):gsub('world', '') .. 'collision')
local movement = require((...):gsub('world', '') .. 'movement')
local defaultConfig = require((...):gsub('world', '') .. 'config')

local stealthWorld = {}
stealthWorld.__index = stealthWorld

local function makeRectCollider(world, x, y, width, height, colliderType)
   local collider = world:newCollider('rectangle', {x, y, width, height})
   collider:setType(colliderType or 'dynamic')
   return collider
end

function stealthWorld.new(config)
   local instance = setmetatable({}, stealthWorld)
   instance.config = config or defaultConfig
   instance.world = bf.newWorld(0, 0, true)
   instance.guards = {}
   return instance
end

function stealthWorld:update(dt)
   self.world:update(dt)
   for _, guard in ipairs(self.guards) do
      guard.proximity:setPosition(guard.body:getX(), guard.body:getY())
   end
end

function stealthWorld:createPlayer(x, y, config)
   local cfg = config or self.config.player
   local collider = makeRectCollider(self.world, x, y, cfg.collider.width, cfg.collider.height, 'dynamic')
   collision.configureSolid(collider, collision.CATEGORY.PLAYER)
   movement.makeTopdownBody(collider, cfg.damping)
   return collider
end

function stealthWorld:createGuard(x, y, config)
   local cfg = config or self.config.guard
   local body = makeRectCollider(self.world, x, y, cfg.collider.width, cfg.collider.height, 'dynamic')
   collision.configureSolid(body, collision.CATEGORY.GUARD)
   movement.makeTopdownBody(body, cfg.damping or self.config.player.damping)
   body.facing_x = cfg.facing_x
   body.facing_y = cfg.facing_y

   local proximity = self.world:newCollider('circle', {x, y, cfg.proximity_radius})
   proximity:setType('kinematic')
   collision.configureSensor(proximity, collision.CATEGORY.PROXIMITY_SENSOR)

   local guard = {
      body = body,
      proximity = proximity,
      config = cfg,
   }
   table.insert(self.guards, guard)
   return guard
end

function stealthWorld:createWall(x, y, w, h)
   local wall = makeRectCollider(self.world, x, y, w, h, 'static')
   collision.configureSolid(wall, collision.CATEGORY.WALL)
   return wall
end

function stealthWorld:createTrigger(x, y, w, h, name)
   local trigger = makeRectCollider(self.world, x, y, w, h, 'static')
   collision.configureSensor(trigger, collision.CATEGORY.TRIGGER)
   trigger.trigger_name = name
   return trigger
end

function stealthWorld:createInteractable(x, y, w, h, id)
   local interactable = makeRectCollider(self.world, x, y, w, h, 'static')
   collision.configureSensor(interactable, collision.CATEGORY.INTERACTABLE)
   interactable.interactable_id = id
   return interactable
end

return stealthWorld
