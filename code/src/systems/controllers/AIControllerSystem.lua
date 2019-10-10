local AIControllerSystem = class("AIControllerSystem", System)

function AIControllerSystem:update(dt)
  if global_ai_active then
    for index, value in pairs(self.targets) do
      AIPhysics = value:get("PositionPhysics")
      AIController = value:get("AIController")
      

      --AI target seeking (Could do more to prioritise targets here)
      master_grids = engine:getEntitiesWithComponent("GridMaster")
      for _,target in pairs(master_grids) do
        target_faction = target:get("Faction")
        if target_faction.faction ~= value:get("Faction").faction then
          target_physics = target:get("PositionPhysics")
          AIController.target_range = math.sqrt((target_physics.body:getY() - AIPhysics.body:getY())^2 + (target_physics.body:getX() - AIPhysics.body:getX())^2) 
          AIController.target_direction = math.atan2(target_physics.body:getY() - AIPhysics.body:getY(), target_physics.body:getX() - AIPhysics.body:getX()) + 1.576
          if AIController.target_range < AIController.range then
            for _,weapon in pairs(value.children) do
              weapon_component = weapon:get("Weapon") 
              if weapon_component ~= nil then
                grid_item = weapon:get("GridItem")
                for _,target_grid in pairs(target.children) do
                  target_grid_item = target_grid:get("GridItem")
                  grid_item.t_pos_grid_physics = math.atan2(target_grid_item.y_pos_grid_physics - grid_item.y_pos_grid_physics, target_grid_item.x_pos_grid_physics - grid_item.x_pos_grid_physics) + 1.5708
                  grid_item.t_render = grid_item.t_pos_grid_physics - AIPhysics.body:getAngle()
                end
                eventmanager:fireEvent(FireEvent(weapon, dt))
              end
            end
          end
        end
      end

      -- Really dumb way to turn towards enemy
      if AIController.target_direction ~= AIPhysics.body:getAngle() then
        if AIController.target_direction > AIPhysics.body:getAngle() then
          AIPhysics.body:applyTorque(300000)
        elseif AIController.target_direction < AIPhysics.body:getAngle() then
          AIPhysics.body:applyTorque(-300000)
        end
      end

      -- Really dumb way to approach
      if AIController.target_range > AIController.range then
        local magnitude_x = math.sin(AIPhysics.body:getAngle())
        local magnitude_y = math.cos(AIPhysics.body:getAngle())*-1
        local force = 10000
        AIPhysics.body:applyForce(magnitude_x * force, magnitude_y * force)
      end
    end
  end
end

function AIControllerSystem:requires()
	return {"AIController"}
end

return AIControllerSystem