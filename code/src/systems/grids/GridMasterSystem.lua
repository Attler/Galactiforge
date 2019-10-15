local TileSetGrid, GridPhysics, GridItem, GridInventory, GridTransfer, GridProcessor, GridBaseGraphic, GridHeat = Component.load({"TileSetGrid", "GridPhysics", "GridItem", "GridInventory", "GridTransfer", "GridProcessor", "GridBaseGraphic", "GridHeat"})
local PlayerController = Component.load({"PlayerController"})
local Weapon, Thruster, Health, DockingLatch = Component.load({"Weapon", "Thruster", "Health", "DockingLatch"})
local FieryDeath = Component.load({"FieryDeath"})

local GridMasterSystem = class("GridMasterSystem", System)

local function addgrid(arg)
  local entity = arg["entity"]
  local x = arg["x"] or nil
  local y = arg["y"] or nil
  local direction = arg["direction"] or 0
  local grid_master = arg["grid_master"] or nil
  local type = arg["type"]

  local new_grid_item = Entity(entity)
  for component_name, component_values in pairs(datasets[type].components) do
    if component_name == "GridItem" then
      new_grid_item:add(GridItem(type, x, y, component_values.category, direction, grid_master.grid_scale))
    elseif component_name == "GridInventory" then
      new_grid_item:add(GridInventory(type))
    elseif component_name == "GridTransfer" then
      new_grid_item:add(GridTransfer(type))
    elseif component_name == "GridProcessor" then
      new_grid_item:add(GridProcessor(type))
    elseif component_name == "GridHeat" then
      new_grid_item:add(GridHeat())
    elseif component_name == "GridBaseGraphic" then
      new_grid_item:add(GridBaseGraphic())
    elseif component_name == "Thruster" then
      new_grid_item:add(Thruster(type, x, y, direction))
      if grid_master.player then
        new_grid_item:add(PlayerController())
      end
    elseif component_name == "Weapon" then
      new_grid_item:add(Weapon(type, x, y))
      if grid_master.player then
        new_grid_item:add(PlayerController())
      end
    elseif component_name == "FieryDeath" then
      new_grid_item:add(FieryDeath())
    elseif component_name == "GridPhysics" then
      new_grid_item:add(GridPhysics())
    elseif component_name == "TileSetGrid" then
      new_grid_item:add(TileSetGrid(tileset_small, type, datasets))
    elseif component_name == "Health" then
      new_grid_item:add(Health(component_values.health))
    end
  end

  grid_master.grid_items[grid_master.grid_specs.allowed_grid.grid_origin.y - y][grid_master.grid_specs.allowed_grid.grid_origin.x - x] = new_grid_item
  grid_master.grid_status[grid_master.grid_specs.allowed_grid.grid_origin.y - y][grid_master.grid_specs.allowed_grid.grid_origin.x - x] = 1
  engine:addEntity(new_grid_item)     

end

function GridMasterSystem:fireEvent(event)
  local grid_master = event.parent:get("GridMaster")
  if event.add_grid then
    if grid_master.grid_status[grid_master.grid_specs.allowed_grid.grid_origin.y - event.y_loc][grid_master.grid_specs.allowed_grid.grid_origin.x - event.x_loc] == 0 then
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
          grid.flag_for_removal = true
          grid_master.grid_items[grid_master.grid_specs.allowed_grid.grid_origin.y - event.y_loc][grid_master.grid_specs.allowed_grid.grid_origin.x - event.x_loc] = 0
         end
      end
    end
  end
end



function GridMasterSystem:onAddEntity(entity)
  local grid_master = entity:get("GridMaster")
  --Add the ship core
  local new_grid_item = Entity(entity)
  new_grid_item:add(FieryDeath())
  new_grid_item:add(GridPhysics())
  new_grid_item:add(TileSetGrid(tileset_small, "ship_core", datasets))
  new_grid_item:add(Health(datasets["ship_core"].health))
  new_grid_item:add(GridItem("ship_core", 0, 0, "technology", 0, grid_master.grid_scale))
  engine:addEntity(new_grid_item)
  grid_master.grid_status[grid_master.grid_specs.allowed_grid.grid_origin.y - 0][grid_master.grid_specs.allowed_grid.grid_origin.x - 0] = 1

  for i,grid_item in pairs(grid_master.grid) do
    if grid_master.grid_specs.allowed_grid.grid_map[grid_master.grid_specs.allowed_grid.grid_origin.y - grid_item.y][grid_master.grid_specs.allowed_grid.grid_origin.x - grid_item.x] == 1 then
      addgrid{type=grid_item.type, entity=entity, x=grid_item.x,y=grid_item.y, grid_master=grid_master, direction=grid_item.direction}
    end
  end
end

function GridMasterSystem:requires()
	return {"GridMaster"}
end

return GridMasterSystem