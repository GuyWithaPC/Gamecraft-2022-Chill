extends RigidBody2D

var dragged = false
var mouse_inside = false
var mouse_down = false
var in_play_area = false
var velocity = Vector2(0,0)

onready var _last_position = position
onready var _play_area = get_tree().get_root().get_child(0).get_node("PlayArea")
onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

export var default_timer = 5.0
onready var timer = default_timer

func _ready():
	# set up event handling
	self.connect("mouse_entered",self,"_on_mouse_entered")
	self.connect("mouse_exited",self,"_on_mouse_exited")
	_play_area.connect("body_entered",self,"_on_body_entered")
	_play_area.connect("body_exited",self,"_on_body_exited")
	self.set_collision_layer_bit(1,true)
	self.input_pickable = true
	self.can_sleep = false
	# misc
	$Sprite.show_behind_parent = true

func _draw():
	var percentage = ((default_timer-timer)/default_timer)
	var start_position = percentage*360
	var color = Color(0,1,0)
	color.h = (1.0/3.0)-(percentage/3.0)
	if (timer/default_timer) < 1:
		draw_circle_arc_poly(Vector2.ZERO,40,start_position,360,color)

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
	
	if !in_play_area:
		timer -= delta
		update()
	else:
		if dragged:
			timer -= delta
			update()
		else:
			if timer < default_timer:
				timer += 2*delta
			update()

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

# helper functions

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)
