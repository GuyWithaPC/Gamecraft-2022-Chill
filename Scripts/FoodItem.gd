extends RigidBody2D

class_name FoodItem

var dragged = false
var mouse_inside = false
var mouse_down = false
var in_play_area = false
var velocity = Vector2(0,0)
var dead = false
var dead_timer = 2.0
var start = true
var start_timer = 1.0

onready var _last_position = start_position
onready var _play_area = get_tree().get_root().get_child(0).get_node("PlayArea")
onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
onready var timer_background = preload("res://Images/timer.png")

export var default_timer = 5.0
onready var timer = default_timer

export var start_position = Vector2(0,0)

# to enable this, the FoodItem it's attached to needs to have a DeathArea Area2D attached
export var dies_from_collision = false

# this one just works as long as you set the margin properly
export var dies_from_angle = false
export var death_angle_margin = 0

func _ready():
	# set up event handling
	self.connect("mouse_entered",self,"_on_mouse_entered")
	self.connect("mouse_exited",self,"_on_mouse_exited")
	_play_area.connect("body_entered",self,"_on_body_entered")
	_play_area.connect("body_exited",self,"_on_body_exited")
	self.set_collision_layer_bit(1,true)
	self.set_collision_layer_bit(0,false)
	self.set_collision_mask_bit(0,false)
	self.input_pickable = true
	self.can_sleep = false
	# misc
	$Sprite.show_behind_parent = true
	add_to_group("Food")
	add_to_group("Table")
	pause_mode = PAUSE_MODE_STOP

func _draw():
	var percentage = ((default_timer-timer)/default_timer)
	var start_position = percentage*360
	var color = Color(0,1,0,0.75)
	color.h = (1.0/3.0)-(percentage/3.0)
	if (timer/default_timer) < 1 and timer > 0:
		draw_texture(timer_background,Vector2(-64,-64),Color(1,1,1,0.25))
		draw_circle_arc_poly(Vector2.ZERO,40,start_position,360,color)

func _process(delta):
	if start:
		start_timer -= delta
		if start_timer <= 0:
			start = false
		return
	
	if !dead and dies_from_collision:
		dead = check_death_from_collision()
	if !dead and dies_from_angle:
		dead = check_death_from_angle()
	
	if dead:
		modulate = Color(1.0,1.0,1.0)
		$Spill.visible = true
		dead_timer -= delta
		if dead_timer <= 0:
			dragged = false
			get_parent().dragging = false
			self.queue_free()
		$Sprite.modulate = Color(1,1,1,0.2)
		if $Spill.modulate == Color(1,1,1):
			$Spill.modulate = Color(randf(),randf(),randf())
	
	if mouse_inside and Input.is_action_just_pressed("left_click"):
		dragged = !dragged
		if !dragged:
			_last_position = position
			get_parent().dragging = false
		if dragged:
			if !get_parent().dragging:
				get_parent().dragging = true
				self.set_collision_layer_bit(0,false)
				self.set_collision_mask_bit(0,false)
				if dies_from_collision:
					$DeathArea.set_collision_layer_bit(0,false)
					$DeathArea.set_collision_mask_bit(0,false)
			else:
				dragged = false
		if !dragged and in_play_area:
			self.set_collision_layer_bit(0,true)
			self.set_collision_mask_bit(0,true)
			if dies_from_collision:
				$DeathArea.set_collision_layer_bit(0,true)
				$DeathArea.set_collision_mask_bit(0,true)
	
	if dragged:
		$Sprite.scale = Vector2(1.1,1.1)
		$Sprite.modulate = Color(1,1,1,0.5)
	elif not dead:
		$Sprite.scale = Vector2(1.0,1.0)
		$Sprite.modulate = Color(1,1,1,1)
	
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
	if timer <= 0:
		get_tree().get_root().get_node("Root").timer_out()

func _integrate_forces(state):
	var lv = state.get_linear_velocity()
	if !start:
		if !in_play_area:
			lv = Vector2.ZERO
			if !dragged:
				state.transform = Transform2D(state.transform.get_rotation(),_last_position)
		if dragged:
			if Input.is_action_just_released("scroll_up"):
				state.angular_velocity = state.angular_velocity - 0.5
			if Input.is_action_just_released("scroll_down"):
				state.angular_velocity = state.angular_velocity + 0.5
			lv = (get_viewport().get_mouse_position() - self.position) * 32
	else:
		lv = (start_position - position) * 3
	state.set_linear_velocity(lv)

# event handling stuff

func _on_mouse_entered():
	mouse_inside = true

func _on_mouse_exited():
	mouse_inside = false

func _on_body_entered(body):
	if body.name == self.name:
		add_to_group("Fridge")
		remove_from_group("Table")
		in_play_area = true

func _on_body_exited(body):
	if body.name == self.name:
		add_to_group("Table")
		remove_from_group("Fridge")
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

func check_death_from_collision():
	for obj in $DeathArea.get_overlapping_bodies():
		if obj.is_in_group("Fridge") and obj.is_in_group("Food") and obj != self and !obj.dragged:
			get_tree().get_root().get_node("Root").food_destroyed()
			return true
	return false

func check_death_from_angle():
	# also change sprite color based on how close it is
	if !dead:
		var tilt = abs(wrapf(self.rotation,-PI,PI)/deg2rad(death_angle_margin))
		modulate = Color(1.0,1.0-tilt,1.0-tilt)
	else:
		modulate = Color(1.0,1.0,1.0)
	if !dragged:
		if !(wrapf(self.rotation,0,2*PI) < deg2rad(death_angle_margin) or wrapf(self.rotation,0,2*PI) > 2*PI-deg2rad(death_angle_margin)):
			get_tree().get_root().get_node("Root").food_destroyed()
			return true
	return false
