extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var dragging = false
var hand_timer = 3.0

onready var food_scene = preload("res://Prefabs/FoodItems.tscn").instance()
onready var hand = $GrabberPath/Grabber
var foods = ["Apple","Milk","Pie","Pizza","Soda","Soup","Tea","TupperwareLg","TupperwareMd","TupperwareSm","Turkey","Watermelon"]
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if randi()%100 == 0:
		var food = randi()%len(foods)
		var summoned = food_scene.get_node(foods[food]).duplicate()
		summoned.start_position = Vector2(randi()%500,randi()%(1080/2)+1080/2)
		summoned.position = summoned.start_position - Vector2(500,0)
		summoned.scale = Vector2(0.5,0.5)
		add_child(summoned)
	if hand_timer > 0:
		hand.unit_offset = lerp(hand.unit_offset,1,delta*5)
	elif hand_timer > -3:
		hand.unit_offset = lerp(hand.unit_offset,0,delta*5)
	else:
		hand_timer = 3
	hand_timer -= delta
