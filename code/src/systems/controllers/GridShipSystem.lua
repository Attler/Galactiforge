local Factory, Weapon, Thruster, TileSetGrid, GridPhysics, GridItem, Health = Component.load({"Factory", "Weapon", "Thruster", "TileSetGrid", "GridPhysics", "GridItem", "Health"})
local FieryDeath = Component.load({"FieryDeath"})

local GridShipSystem = class("GridShipSystem", System)

function GridShipSystem:fireEvent(event)
  local ship = event.parent:get("Ship")
  if event.add_grid then
    if ship.grid_status[ship.ship_specs.allowed_grid.grid_origin.y - event.y_loc][ship.ship_specs.allowed_grid.grid_origin.x - event.x_loc] == 0 then
      local type = global_component_name_list[global_component_index]
      local direction = global_component_directions[global_component_direction_index]
      local new_grid_item = Entity(event.parent)
      
      new_grid_item:add(FieryDeath())
      new_grid_item:add(GridPhysics())
      new_grid_item:add(TileSetGrid(tileset_small, type, datasets))
      new_grid_item:add(Health(datasets[type].health))

      if datasets[type].category == "factory" then 
        new_grid_item:add(Factory())
        new_grid_item:add(GridItem(type, event.x_loc, event.y_loc, datasets[type].category, true, 0))
      
      elseif datasets[type].category == "weapon" then 
        new_grid_item:add(Weapon(type, event.x_loc, event.y_loc))
        new_grid_item:add(GridItem(type, event.x_loc, event.y_loc, datasets[type].category, false, 0))
      
      elseif datasets[type].category == "thruster" then
        new_grid_item:add(Thruster(type, event.x_loc, event.y_loc, direction))
        new_grid_item:add(GridItem(type, event.x_loc, event.y_loc, datasets[type].category, false, direction))
      end
      engine:addEntity(new_grid_item)
    end
    ship.grid_status[ship.ship_specs.allowed_grid.grid_origin.y - event.y_loc][ship.ship_specs.allowed_grid.grid_origin.x - event.x_loc] = 1
  else
    viable_grids = engine:getEntitiesWithComponent("GridItem")
    for i,v in pairs(viable_grids) do
      grid = v:get("GridItem")
      parent = v:getParent()
      if parent == event.parent then
        if grid.x == event.x_loc and grid.y == event.y_loc then
          grid.flag_for_removal = true
         end
      end
    end
  end
end

function GridShipSystem:onAddEntity(entity)
  local gridship = entity:get("GridShip")
  local ship = entity:get("Ship")

  for i,grid_item in pairs(gridship.grid) do
    if ship.ship_specs.allowed_grid.grid_map[ship.ship_specs.allowed_grid.grid_origin.y - grid_item.y][ship.ship_specs.allowed_grid.grid_origin.x - grid_item.x] == 1 then

      local new_grid_item = Entity(entity)
      new_grid_item:add(FieryDeath())
      new_grid_item:add(GridPhysics())
      new_grid_item:add(TileSetGrid(tileset_small, grid_item.type, datasets))
      new_grid_item:add(Health(datasets[grid_item.type].health))

      if grid_item.category == "factory" then 
        new_grid_item:add(Factory())
        new_grid_item:add(GridItem(grid_item.type, grid_item.x, grid_item.y, grid_item.category, true, 0))
      
      elseif grid_item.category == "weapon" then 
        new_grid_item:add(Weapon(grid_item.type, grid_item.x, grid_item.y))
        new_grid_item:add(GridItem(grid_item.type, grid_item.x, grid_item.y, grid_item.category, false, 0))
        
      elseif grid_item.category == "thruster" then
        new_grid_item:add(Thruster(grid_item.type, grid_item.x, grid_item.y, grid_item.direction))
        new_grid_item:add(GridItem(grid_item.type, grid_item.x, grid_item.y, grid_item.category, false, grid_item.direction))
      end
      engine:addEntity(new_grid_item)
      ship.grid_status[ship.ship_specs.allowed_grid.grid_origin.y - grid_item.y][ship.ship_specs.allowed_grid.grid_origin.x - grid_item.x] = 1
    end
  end
end

function GridShipSystem:requires()
	return {"GridShip", "Ship"}
end

return GridShipSystem