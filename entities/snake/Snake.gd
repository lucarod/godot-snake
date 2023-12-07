extends Node2D

signal move_triggered(entity, direction)
signal generated_tail_segment(segment, segment_position)
signal body_segment_move_triggered(segment, segment_position)

onready var direction = Vector2()
onready var new_direction = Vector2()
onready var can_move = false
onready var body_segments = [self]

const SCENE_TAIL = preload("res://entities/tail/Tail.tscn")

func _process(delta):
	get_direction()
	if direction != Vector2() and can_move:
		var old_pos_of_segment_in_front = self.position
		emit_signal("move_triggered", self, direction)
		if body_segments.size() > 1:
			for i in range(1, body_segments.size()):
				var temp_pos = body_segments[i].position
				emit_signal("body_segment_move_triggered", body_segments[i], old_pos_of_segment_in_front)
				old_pos_of_segment_in_front = temp_pos
		
		can_move = false
		$MoveDelay.start()
		
func get_direction():
	if Input.is_action_pressed("ui_up"):
		new_direction = Vector2(0, -1)
	elif Input.is_action_pressed("ui_down"):
		new_direction = Vector2(0, 1)
	elif Input.is_action_pressed("ui_left"):
		new_direction = Vector2(-1, 0)
	elif Input.is_action_pressed("ui_right"):
		new_direction = Vector2(1, 0)
		
	if new_direction != direction * -1:
		direction = new_direction


func _on_MoveDelay_timeout():
	can_move = true

func eat_food():
	var tail_segment = SCENE_TAIL.instance()
	body_segments.append(tail_segment)
	emit_signal("generated_tail_segment", tail_segment, body_segments[-2].position)
