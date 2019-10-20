local GridProcessor = Component.create("GridProcessor")
function GridProcessor:initialize(component_values)
  self.resource_names = {}
  self.resource_produced = {}
  for resource_name, resource_values in pairs(component_values.resource_produced) do
    self.resource_produced[resource_name] = {}
    self.resource_produced[resource_name].use_rate = resource_values.use_rate
    self.resource_produced[resource_name].active = false
    table.insert(self.resource_names, resource_name)
  end

  for resource_name,resource_values in pairs(self.resource_produced) do
    resource_values.active = true
    break
  end

  
  self.next_resource = 1
  self.process_delay = component_values.process_rate
  self.timer = 0

end