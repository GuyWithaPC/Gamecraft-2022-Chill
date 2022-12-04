extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var dragging = false
var lose = false
var wanting_food = null
var score = 0
var target_score = 0
var blur_lod = 5.0

var time_elapsed = 0

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
	"TupperwareMd" : preload("res://Images/Food/tupperware_md.png"),
	"TupperwareSm" : preload("res://Images/Food/tupperware_sm.png"),
	"Turkey" : preload("res://Images/Food/turkey.png"),
	"Watermelon" : preload("res://Images/Food/watermelon.png")
}

# The z-index for the next item's spill texture mask.
var spill_mask_index = 100
# The maximum z-index for an item's spill texture mask
var max_spill_mask_index = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$UI/LoseScreen.rotation = 4*PI

func food_destroyed():
	target_score -= 20

func timer_out():
	get_tree().paused = true
	for obj in get_tree().get_nodes_in_group("Fridge"):
		target_score += 5
		obj.queue_free()
	for obj in get_tree().get_nodes_in_group("Table"):
		obj.queue_free()
	lose = true
	dragging = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	
	# First 10 seconds are normal, then it starts speeding up
	var music_speed = clamp(1 + ((time_elapsed - 15) / 500), 1, 1.5)

	$MusicPlayer.pitch_scale = music_speed
	
	if lose:
		blur_lod = lerp(blur_lod,2.5,delta)
		$UI/LoseScreen.show()
		$UI/LoseScreen.rotation = lerp($UI/LoseScreen.rotation,0,delta)
		$UI/LoseScreen.scale = lerp($UI/LoseScreen.scale,Vector2(1.5,1.5),delta)
	else:
		blur_lod = lerp(blur_lod,0,delta*2)
	$UI/Blur.get_material().set_shader_param("lod",blur_lod)
	score = lerp(score,target_score,delta*10)
	$UI/Score.text = "Score: " + str(round(score))
	if dragging:
		Input.set_custom_mouse_cursor(grabbed_cursor,0,Vector2(30,30))
	else:
		if Input.is_action_pressed("left_click"):
			Input.set_custom_mouse_cursor(grabbed_cursor,0,Vector2(30,30))
		else:
			Input.set_custom_mouse_cursor(open_cursor,0,Vector2(30,30))
	
	if randi()%400 == 0:
		# Summon a food item
		var food = randi()%len(foods)
		var summoned = food_scene.get_node(foods[food]).duplicate()
		# Set its values
		summoned.start_position = Vector2(randi()%300+100,randi()%(1080/2)+1080/2)
		summoned.position = summoned.start_position - Vector2(500,0)
		summoned.scale = Vector2(0.5,0.5)
		# Set up its spill mask
		if spill_mask_index > max_spill_mask_index:
			spill_mask_index = 100
		summoned.get_child(2).z_index = spill_mask_index
		summoned.get_child(3).range_z_min = spill_mask_index
		summoned.get_child(3).range_z_max = spill_mask_index
		spill_mask_index += 1
		# Add it to this node
		add_child(summoned)
	if randi()%400 == 0 and !wanting_food and len(get_tree().get_nodes_in_group("Fridge")) > 0:
		var random_food = get_tree().get_nodes_in_group("Fridge")[randi()%len(get_tree().get_nodes_in_group("Fridge"))]
		var food = random_food.name.replace("@","").rstrip("0123456789")
		print("wants: "+food)
		wanting_food = food
		grab_region.ask()
	
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
					target_score += 10
					wanting_food = null
					grab_region.retreat()
					break
	else:
		hand.unit_offset = lerp(hand.unit_offset,0,delta*5)
		bubble.rotation_degrees = lerp(bubble.rotation_degrees,-90,delta*5)
