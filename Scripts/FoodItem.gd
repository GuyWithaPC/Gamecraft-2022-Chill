extends RigidBody2D

var dragged = false
var mouse_inside = false
var mouse_down = false
var in_play_area = false
var velocity = Vector2(0,0)
onready var _last_position = position
onready var _play_area = get_tree().get_root().get_child(0).get_node("PlayArea")
onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# set up event handling
	self.connect("mouse_entered",self,"_on_mouse_entered")
	self.connect("mouse_exited",self,"_on_mouse_exited")
	_play_area.connect("body_entered",self,"_on_body_entered")
	_play_area.connect("body_exited",self,"_on_body_exited")
	self.set_collision_layer_bit(1,true)
	self.input_pickable = true
	self.can_sleep = false

func _process(delta):
	if mouse_inside and Input.is_action_just_pressed("left_click"):
		dragged = !dragged
		if !dragged:
			_last_position = position
		if dragged:
			self.set_collision_layer_bit(0,false)
			self.set_collision_mask_bit(0,false)
		if !dragged and in_play_area:
			self.set_collision_layer_bit(0,true)
			self.set_collision_mask_bit(0,true)
	
	if dragged:
		$Sprite.scale = Vector2(1.1,1.1)
		$Sprite.self_modulate = Color(1,1,1,0.5)
	else:
		$Sprite.scale = Vector2(1.0,1.0)
		$Sprite.self_modulate = Color(1,1,1,1)

func _integrate_forces(state):
	var lv = state.get_linear_velocity()
	if !in_play_area:
		lv = Vector2.ZERO
		if !dragged:
			state.transform = Transform2D(state.transform.get_rotation(),_last_position)
	if dragged:
		lv = (get_viewport().get_mouse_position() - self.position) * 32
	state.set_linear_velocity(lv)

# event handling stuff

func _on_mouse_entered():
	mouse_inside = true

func _on_mouse_exited():
	mouse_inside = false

func _on_body_entered(body):
	if body.name == self.name:
		in_play_area = true

func _on_body_exited(body):
	if body.name == self.name:
		in_play_area = false
