extends RigidBody2D

class_name FoodItem

var _dragged = false
var _in_play_area = false
onready var _play_area = get_tree().get_root().get_child(0).get_node("PlayArea")

func _ready():
	# set up event handling
	self.connect("input_event",self,"_on_input_event")
	_play_area.connect("body_entered",self,"_on_body_entered")
	_play_area.connect("body_exited",self,"_on_body_exited")
	self.input_pickable = true

func _process(delta):
	if _dragged:
		self.position = get_viewport().get_mouse_position()
		if _in_play_area:
			self.scale = Vector2(1.25,1.25)
			if Input.is_action_just_pressed("left_click"):
				_dragged = false

func _physics_process(delta):
	# choose whether to have physics disabled or running
	if _dragged or !_in_play_area:
		self.sleeping = true
	else:
		self.sleeping = false

# event handling stuff

func _on_input_event(viewport, event, shape_idx):
	# this event handles getting clicked to begin dragging
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			_dragged = !_dragged

func _on_body_entered(body):
	print(body.name)
	if body.name == self.name:
		print("entered play area")
		_in_play_area = true

func _on_body_exited(body):
	if body.name == self.name:
		print("exited play area")
		_in_play_area = false
