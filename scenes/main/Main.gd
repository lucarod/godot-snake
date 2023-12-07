extends Node

const SCENE_FOOD = preload("res://entities/food/Food.tscn")
const SCENE_SNAKE = preload("res://entities/snake/Snake.tscn")

onready var grid = get_node("Grid")

var player

func _ready():
	randomize()
	setup_entities()

func setup_entities():
	player = SCENE_SNAKE.instance()
	player.connect("move_triggered", self, "_on_Snake_move_triggered")
	player.connect("generated_tail_segment", self, "_on_Snake_generated_tail_segment")
	player.connect("body_segment_move_triggered", self, "_on_Snake_body_segment_move_triggered")
	add_child(player)
	grid.place_entity_at_random_pos(player)
	
	setup_food_entity()
	
func setup_food_entity():
	var food_instance = SCENE_FOOD.instance()
	add_child(food_instance)
	grid.place_entity_at_random_pos(food_instance)

func _on_Snake_move_triggered(entity, direction):
	grid.move_entity_in_direction(entity, direction)


func _on_Grid_moved_into_death():
	delete_entities_of_group("Food")
	delete_entities_of_group("Player")
	
	setup_entities()

func delete_entities_of_group(name):
	var entities = get_tree().get_nodes_in_group(name)
	for entity in entities:
		entity.queue_free() 
		
func _on_Grid_moved_onto_food(food_entity, entity):
	if entity.has_method("eat_food"):
		entity.eat_food()
		food_entity.queue_free()
		setup_food_entity()
		
func _on_Snake_generated_tail_segment(segment, segment_position):
	add_child(segment)
	grid.place_entity(segment, grid.world_to_map(segment_position))
	
func _on_Snake_body_segment_move_triggered(segment, segment_position):
	grid.move_entity_in_position(segment, segment_position)
