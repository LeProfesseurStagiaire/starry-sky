extends Node2D


var nb_point = float(5) 
var time_to_start = 0.5
onready var point_preload = preload("res://points/point.tscn")
onready var min_point_spawn_pos = $point_spwan_shape.rect_position
onready var max_point_spawn_pos = $point_spwan_shape.rect_size + min_point_spawn_pos
var nb_connection = 0
var last_point
var can_play = false
var score = -1
var time_left = 10.0
var game_ended = false


func _ready():
	$timer/time_left.text = str(int(time_left))
	randomize()
	reset_game(true)

func end_game():
	$end.play()
	$timer/AnimationPlayer.play("time_pass")
	$mouse/Line2D.hide()
	$end_score/score.text = "score: " +str(score)
	$end_score/score/best_score/AnimationPlayer.play("oui")
	can_play = false
	despawn_point(false)
	$quit_game_timer.start(5)
	if score > global.best_score:
		global.best_score = score
		$end_score/score/best_score.show()


func reset_game(win):
	if win :
		score += 1
	can_play = false
	Input.set_mouse_mode(1)
	despawn_point(win)
	$end_timer.start()


func despawn_point(win):
	for x in $point_container.get_children():
		x.start_despawn(win)
	nb_connection = 0
	last_point = null


func spawn_point():
	var nb = 0
	while nb < nb_point:
		nb += 1
		var point = point_preload.instance()
		$point_container.add_child(point)
		point.position = Vector2(rand_range(min_point_spawn_pos.x,max_point_spawn_pos.x),rand_range(min_point_spawn_pos.y,max_point_spawn_pos.y))
		point.get_node("timer_spawn").start((time_to_start/nb_point) * float(nb))
		if !last_point:
			last_point = point
			last_point.position = get_global_mouse_position()
#			Input.warp_mouse_position(last_point.position)
			set_base_point(point)
	$begining_timer.start(time_to_start)


func mouse_enter_point(point):
	if can_play:
		nb_connection += 1
		point.connect_point(last_point)
		set_base_point(point)
		if nb_connection >= nb_point-1:
			nb_point += 1
			time_left += 4.0
			reset_game(true)
			$AnimationPlayer2.play("get")


func set_base_point(point):
	point.get_point()
	$mouse/RayCast2D.enabled = false
	last_point = point
	var pos = point.position
	$mouse/Line2D.points[0] = pos
	$mouse/Line2D.points[1] = pos
	if can_play:
		$mouse/RayCast2D.enabled = true


func _process(delta):
	if can_play:
		time_left -= 1.0 * delta
		if time_left <= -0.9:
			end_game()
			return
		$timer/time_left.text = str(int(time_left))
		$mouse/Line2D.points[1] = get_global_mouse_position()
		$mouse/RayCast2D.position = get_global_mouse_position()
		$mouse/RayCast2D.cast_to = last_point.position - $mouse/RayCast2D.position
		if $mouse/RayCast2D.is_colliding():
			if $mouse/RayCast2D.get_collider().is_in_group("point") && ! $mouse/RayCast2D.get_collider().get_parent().connected:
				mouse_enter_point($mouse/RayCast2D.get_collider().get_parent())
			if $mouse/RayCast2D.get_collider().is_in_group("connected_line"):
				reset_game(false)
				$end.play()
#	elif last_point:
#		Input.warp_mouse_position(last_point.global_position)


func _on_begining_timer_timeout():
	$mouse/RayCast2D.enabled = true
	$mouse/Line2D.show()
	$timer/AnimationPlayer.play("time_pass")
	Input.set_mouse_mode(0)
	can_play = true


func _on_end_timer_timeout():
	spawn_point()


func _on_quit_game_timer_timeout():
	get_tree().change_scene("res://main_menu/menu.tscn")
