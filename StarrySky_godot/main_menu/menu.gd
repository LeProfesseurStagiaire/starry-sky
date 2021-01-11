extends Node2D


func _ready():
	$container/best_score.text = "Best score : "+str(global.best_score)


func _on_ui_button_play_pressed():
	$AnimationPlayer.play("begin")


func play():
	get_tree().change_scene("res://main/main.tscn")


func _on_ui_button_quit_pressed():
	get_tree().quit()
