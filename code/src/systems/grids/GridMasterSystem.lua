local GridMasterSystem = class("GridMasterSystem", System)

local function addgrid(arg)
  local entity = arg["entity"]
  local x = arg["x"] or nil
  local y = arg["y"] or nil
  local direction = arg["direction"] or 0
  local grid_master = arg["grid_master"] or nil
  local type = arg["type"]
  local grid_item = arg["grid_item"] or nil

  local new_grid_item = Entity(entity)
  new_grid_item.type = type
  new_grid_item.x = x
  new_grid_item.y = y
  new_grid_item.direction = direction

  for component_name, component_values in pairs(datasets[type].components) do
    if component_name == "GridItem" then
      new_grid_item:add(global_components.GridItem(type, x, y, direction, grid_master.grid_scale))
    elseif component_name == "GridInventory" then
      new_grid_item:add(global_components.GridInventory(component_values))
    elseif component_name == "GridTransfer" then
      new_grid_item:add(global_components.GridTransfer(component_values))
    elseif component_name == "GridProcessor" then
      new_grid_item:add(global_components.GridProcessor(component_values, grid_item.active_resource))
    elseif component_name == "GridHeat" then
      new_grid_item:add(global_components.GridHeat(component_values))
    elseif component_name == "GridBaseGraphic" then
      new_grid_item:add(global_components.GridBaseGraphic())
    elseif component_name == "Thruster" then
      new_grid_item:add(global_components.Thruster(component_values, direction))
      if grid_master.player then
        new_grid_item:add(global_components.PlayerController())
      end
    elseif component_name == "Weapon" then
      new_grid_item:add(global_components.Weapon(component_values))
      if grid_master.player then
        new_grid_item:add(global_components.PlayerController())
      end
    elseif component_name == "FieryDeath" then
      new_grid_item:add(global_components.FieryDeath())
    elseif component_name == "GridPhysics" then
      new_grid_item:add(global_components.GridPhysics())
    elseif component_name == "TileSetGrid" then
      new_grid_item:add(global_components.TileSetGrid(component_values, tileset_small))
    elseif component_name == "Health" then
      new_grid_item:add(global_components.Health(component_values))
    end
  end

  grid_master.grid_items[grid_master.grid_specs.allowed_grid.grid_origin.y - y][grid_master.grid_specs.allowed_grid.grid_origin.x - x] = new_grid_item
  engine:addEntity(new_grid_item)    
end

function GridMasterSystem:fireEvent(event)
  local grid_master = event.parent:get("GridMaster")
  if event.add_grid then
    if grid_master.grid_items[grid_master.grid_specs.allowed_grid.grid_origin.y - event.y_loc][grid_master.grid_specs.allowed_grid.grid_origin.x - event.x_loc] == 0 then
      local type = global_component_name_list[global_component_index]
      local direction = global_component_directions[global_component_direction_index]
      addgrid{type=type, entity=event.parent, x=event.x_loc, y=event.y_loc, grid_master=grid_master, direction=direction}
    end
  else
    viable_grids = engine:getEntitiesWithComponent("GridItem")
    for i,v in pairs(viable_grids) do
      grid = v:get("GridItem")
      parent = v:getParent()
      if parent == event.parent then
        if grid.x == event.x_loc and grid.y == event.y_loc then
          grid_master.grid_items[grid_master.grid_specs.allowed_grid.grid_origin.y - event.y_loc][grid_master.grid_specs.allowed_grid.grid_origin.x - event.x_loc] = 0
          engine:removeEntity(v)
        end
      end
    end
  end
end



function GridMasterSystem:onAddEntity(entity)
  local grid_master = entity:get("GridMaster")
  for _,grid_item in pairs(grid_master.grid) do
    if grid_master.grid_specs.allowed_grid.grid_map[grid_master.grid_specs.allowed_grid.grid_origin.y - grid_item.y][grid_master.grid_specs.allowed_grid.grid_origin.x - grid_item.x] == 1 then
      addgrid{type=grid_item.type, entity=entity, x=grid_item.x,y=grid_item.y, grid_master=grid_master, direction=grid_item.direction, grid_item=grid_item}
    end
  end
end

function GridMasterSystem:requires()
	return {"GridMaster"}
end

return GridMasterSystem