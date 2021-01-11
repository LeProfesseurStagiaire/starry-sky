extends Node2D

var connected = false
var getted = false
onready var end_tex = preload("res://assets/img/point_ended.png")


func _ready():
	$spawn_audio.pitch_scale = rand_range(1,2)
	$get_audio.pitch_scale = rand_range(0.8,1.5)
	$area_ray/CollisionShape2D.shape = $area_ray/CollisionShape2D.shape.duplicate()
	scale = Vector2(0,0)


func _on_area_mouse_entered():
	if !connected:
		get_tree().get_current_scene().mouse_enter_point(self)


func connect_point(last_point):
	$line.points[1] = last_point.position- position
	$area_ray.look_at(last_point.position)
	$area_ray/CollisionShape2D.shape.extents.y = position.distance_to(last_point.position)/2 - ($img.texture.get_size()/2*$img.scale).y-5
	$area_ray.global_position =  ($area_ray.global_position + last_point.position)/2
	$area_ray/CollisionShape2D.disabled = false
	connected = true


func get_point():
	if !getted:
		getted = true
		connected = true
		$get_audio.play()
		$connected.interpolate_property($img,"scale",$img.scale,Vector2(0.25,0.25),1,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
		$connected.interpolate_property($img,"modulate",$img.modulate,Color(0.568627, 0.376471, 0.992157,1),0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$connected.interpolate_property($getting_img,"scale",$img.scale,Vector2(0.6,0.6),0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$connected.interpolate_property($getting_img,"modulate",$img.modulate,Color(0.4, 0.501961, 1,0),0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$connected.start()
		$img.texture = end_tex


func _on_Timer_timeout():
	spawn()


func spawn():
	$spawn_audio.play()
	$tween_spawn.interpolate_property(self,"scale",scale,Vector2(1,1),0.4,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
	$tween_despawn.interpolate_property(self,"modulate",modulate,Color(1,1,1,1),0.4,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
	$tween_spawn.start()


func despawn():
	$tween_despawn.interpolate_property(self,"scale",scale,Vector2(0,0),0.6,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$tween_despawn.interpolate_property(self,"modulate",modulate,Color(1,1,1,0),0.6,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$tween_despawn.start()


func start_despawn(win):
	$area_ray/CollisionShape2D.disabled = true
	$area/col.disabled = true
	$img.texture = end_tex
	$connected.stop_all()
	$getting_img.hide()
	if win :
		$tween_start_despawn.interpolate_property($line,"default_color",$line.default_color,Color(0.698039, 1, 0.709804),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$tween_start_despawn.interpolate_property($img,"modulate",$img.modulate,Color(0.698039, 1, 0.709804),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$stars.emitting = true
	else :
		$tween_start_despawn.interpolate_property($line,"default_color",$line.default_color,Color(0.823529, 0.14902, 0.14902),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$tween_start_despawn.interpolate_property($img,"modulate",$img.modulate,Color(0.823529, 0.14902, 0.14902),0.3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$tween_start_despawn.interpolate_property($img,"scale",$img.scale,Vector2(0.2,0.2),0.8,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
	$tween_start_despawn.interpolate_property($line,"width",$line.width,6,0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$tween_start_despawn.start()
	$timer_despawn.start(1)


func _on_tween_despawn_tween_all_completed():
	queue_free()


func _on_timer_despawn_timeout():
	despawn()
