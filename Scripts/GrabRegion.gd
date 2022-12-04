extends Area2D

export var default_timer = 10
onready var timer = default_timer
onready var timer_background = preload("res://Images/timer.png")
var asking = false

func _draw():
	var percentage = ((default_timer-timer)/default_timer)
	var start_position = percentage*360
	var color = Color(0,1,0,0.75)
	color.h = (1.0/3.0)-(percentage/3.0)
	if (timer/default_timer) < 1 and timer > 0:
		draw_texture(timer_background,Vector2(-64,-64),Color(1,1,1,0.25))
		draw_circle_arc_poly(Vector2(0,0),40,start_position,360,color)


func _process(delta):
	update()
	if asking:
		timer -= delta
		if timer <= 0:
			get_tree().get_root().get_node("Root").timer_out()

func ask():
	asking = true

func retreat():
	asking = false
	timer = default_timer

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)
