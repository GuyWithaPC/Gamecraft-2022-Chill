extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var dragging = false
var wanting_food = null

onready var food_scene = preload("res://Prefabs/FoodItems.tscn").instance()
onready var grabbed_cursor = preload("res://Images/cursor/cursor_closed.png")
onready var open_cursor = preload("res://Images/cursor/cursor_open.png")
onready var hand = $GrabberPath/Grabber
onready var bubble = $GrabberPath/Grabber/SpeechBubble
onready var grab_region = $GrabberPath/Grabber/GrabRegion
onready var want_speech = $GrabberPath/Grabber/SpeechBubble/SpeechWanting
var foods = ["Apple","Milk","Pie","Pizza","Soda","Soup","Tea","TupperwareLg","TupperwareMd","TupperwareSm","Turkey","Watermelon"]
onready var food_sprites = {
	"Apple" : preload("res://Images/Food/apple.png"),
	"Milk" : preload("res://Images/Food/milk.png"),
	"Pie" : preload("res://Images/Food/pie.png"),
	"Pizza" : preload("res://Images/Food/pizza.png"),
	"Soda" : preload("res://Images/Food/soda.png"),
	"Soup" : preload("res://Images/Food/soup.png"),
	"Tea" : preload("res://Images/Food/tea.png"),
	"TupperwareLg" : preload("res://Images/Food/tupperware_lg.png"),
	"TupperwareSm" : preload("res://Images/Food/tupperware_sm.png"),
	"Turkey" : preload("res://Images/Food/turkey.png"),
	"Watermelon" : preload("res://Images/Food/watermelon.png")
}
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dragging:
		Input.set_custom_mouse_cursor(grabbed_cursor,0,Vector2(50,30))
	else:
		Input.set_custom_mouse_cursor(open_cursor,0,Vector2(50,30))
	
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
		want_speech.texture = food_sprites[wanting_food]
		if hand.unit_offset < 0.95:
			hand.unit_offset = lerp(hand.unit_offset,1,delta*5)
			bubble.rotation_degrees = lerp(bubble.rotation_degrees,0,delta*5)
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
		bubble.rotation_degrees = lerp(bubble.rotation_degrees,-90,delta*5)
