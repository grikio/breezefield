local collision = {}

collision.CATEGORY = {
   PLAYER = 1,
   GUARD = 2,
   WALL = 3,
   TRIGGER = 4,
   PROXIMITY_SENSOR = 5,
   VISION_SENSOR = 6,
   INTERACTABLE = 7,
}

function collision.applyCategory(collider, category)
   collider:setCategory(category)
end

function collision.configureSolid(collider, category, masks)
   collision.applyCategory(collider, category)
   collider:setSensor(false)
   if masks then
      collider:setMask(unpack(masks))
   end
end

function collision.configureSensor(collider, category, masks)
   collision.applyCategory(collider, category)
   collider:setSensor(true)
   if masks then
      collider:setMask(unpack(masks))
   end
end

function collision.getCategory(collider)
   local categories = {collider:getCategory()}
   return categories[1]
end

return collision
