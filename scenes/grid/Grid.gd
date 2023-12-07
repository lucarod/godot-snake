extends TileMap

signal moved_into_death
signal moved_onto_food(food_entity, entity)

onready var half_cell_size = get_cell_size() / 2

onready var grid_size = Vector2(32, 24)
var grid

func _ready():
	setup_grid()

func setup_grid():
	grid = []
	
	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			grid[x].append(null)
			
func get_entity_of_cell(grid_pos):
	return grid[grid_pos.x][grid_pos.y]
	
func set_entity_in_cell(entity, grid_pos):
	grid[grid_pos.x][grid_pos.y] = entity

func place_entity(entity, grid_pos):
	set_entity_in_cell(entity, grid_pos)
	entity.set_position(map_to_world(grid_pos) + half_cell_size)
	
func place_entity_at_random_pos(entity):
	var has_random_pos = false
	var random_grid_pos
	
	while has_random_pos == false:
		var temp_pos = Vector2(randi() % int(grid_size.x), randi() % int(grid_size.y))
		if get_entity_of_cell(temp_pos) == null:
			random_grid_pos = temp_pos
			has_random_pos = true
			
	place_entity(entity, random_grid_pos)

func move_entity_in_direction(entity, direction):
	var old_grid_pos = world_to_map(entity.position)
	var new_grid_pos = old_grid_pos + direction
	
	if !is_cell_inside_bounds(new_grid_pos):
		setup_grid()
		emit_signal("moved_into_death")
		return
	
	set_entity_in_cell(null, old_grid_pos)
	
	var entity_of_new_cell = get_entity_of_cell(new_grid_pos)
	
	if entity_of_new_cell != null:
		if entity_of_new_cell.is_in_group("Player"):
			setup_grid()
			emit_signal("moved_into_death")
			return
		elif entity_of_new_cell.is_in_group("Food"):
			emit_signal("moved_onto_food", entity_of_new_cell, entity)
	
	place_entity(entity, new_grid_pos)
	
func move_entity_in_position(entity, new_pos):
	var old_grid_position = world_to_map(entity.position)
	var new_grid_position = world_to_map(new_pos)
	
	set_entity_in_cell(null, old_grid_position)
	place_entity(entity, new_grid_position)
#	entity.set_position(new_pos)

func is_cell_inside_bounds(cell_pos):
	if cell_pos.x < grid_size.x and cell_pos.x >= 0 \
		and cell_pos.y < grid_size.y and cell_pos.y >=0:
			return true
	else:
		return false
