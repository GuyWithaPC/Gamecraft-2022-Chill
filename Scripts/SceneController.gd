extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var dragging = false
var wanting_food = null

onready var food_scene = preload("res://Prefabs/FoodItems.tscn").instance()
onready var hand = $GrabberPath/Grabber
onready var grab_region = $GrabberPath/Grabber/GrabRegion
var foods = ["Apple","Milk","Pie","Pizza","Soda","Soup","Tea","TupperwareLg","TupperwareMd","TupperwareSm","Turkey","Watermelon"]
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if randi()%200 == 0:
		var food = randi()%len(foods)
		var summoned = food_scene.get_node(foods[food]).duplicate()
		summoned.start_position = Vector2(randi()%500,randi()%(1080/2)+1080/2)
		summoned.position = summoned.start_position - Vector2(500,0)
		summoned.scale = Vector2(0.5,0.5)
		add_child(summoned)
	if randi()%500 == 0 and !wanting_food:
		var food = foods[randi()%len(foods)]
		print("wants: "+food)
		wanting_food = food
	
	if wanting_food != null:
		if hand.unit_offset < 0.95:
			hand.unit_offset = lerp(hand.unit_offset,1,delta*5)
		else:
			hand.unit_offset = 1
		for obj in grab_region.get_overlapping_bodies():
			if obj.is_in_group("Food"):
				if wanting_food in obj.name and !obj.dragged:
					obj.queue_free()
					wanting_food = null
					break
	else:
		hand.unit_offset = lerp(hand.unit_offset,0,delta*5)
