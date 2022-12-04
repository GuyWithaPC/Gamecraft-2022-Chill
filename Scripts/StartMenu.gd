extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lod = 0.0
var max_lod = 5.0
var starting = false

onready var grabbed_cursor = preload("res://Images/cursor/cursor_closed.png")
onready var open_cursor = preload("res://Images/cursor/cursor_open.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("left_click"):
		Input.set_custom_mouse_cursor(grabbed_cursor,0,Vector2(30,30))
	else:
		Input.set_custom_mouse_cursor(open_cursor,0,Vector2(30,30))
	
	if starting:
		lod += delta*5
		$Blur.get_material().set_shader_param("lod",lod)
		if lod >= 5:
			get_tree().change_scene("res://Scenes/Play.tscn")


func _on_StartButton_pressed():
	starting = true
