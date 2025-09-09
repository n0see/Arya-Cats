extends Node2D
const SAVE_PATH = "res://Saves/cats.json"
var newcat_scene = preload("res://Scenes/cat.tscn")
var bounds = Vector2(0,400)

func _ready() -> void:
	var cats = load_cats()
	var save_button = $customize.find_child("Save")
	save_button.pressed.connect(Callable(self, "_on_save_button_pressed"))
	print ("save button is :" ,save_button)
	var delete_button = $customize.find_child("Delete")
	delete_button.pressed.connect(Callable(self, "_on_delete_button_pressed"))
	for cat in cats  :
		add_cat_to_scene(cat)
func load_cats():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("cats.json not found, returning empty array.")
		return []
	
	var json_string = file.get_as_text()
	var json_data = JSON.new()
	var parse_result = json_data.parse(json_string)
	
	if parse_result != OK:
		print("Failed to parse JSON: ", json_data.get_error_message(), " at line ", json_data.get_error_line())
		return []
		
	var data = json_data.get_data()
	if not data is Array:
		print("JSON file does not contain an array.")
		return []
		
	return data
func _on_delete_button_pressed(): 
	var cat_name = $customize/Control/HBoxContainer3/TextEdit.text
	if cat_name == "":
		print("Name cannot be empty!")
		return
	delete_cat(cat_name)
func _on_save_button_pressed() : 
	var cat_name = $customize/Control/HBoxContainer3/TextEdit.text
	if cat_name == "":
		print("Name cannot be empty!")
		return
	var body_color = $customize/Control.body_color
	var pattern_color = $customize/Control.pattern_color
	print("pattern_color is : ",pattern_color)
	var cat_stats = {
		"body_color": body_color,
		"name": cat_name,
		"pattern_color": pattern_color,
		"bounds" : bounds
	}
	save_cat(cat_stats)
func add_cat_to_scene(cat_stats): 
	var newcat = newcat_scene.instantiate()
	cat_stats['bounds'] = bounds
	print('added a new cat : ',cat_stats)
	newcat.create_cat(cat_stats)
	#newcat.set_color("Body",cat["body_color"])
	#newcat.set_color("Pattern",cat["pattern_color"])
	newcat.position = Vector2(randi_range(bounds.x,bounds.y),300)
	self.add_child(newcat)
	
func save_cat(cat_stats):
	var cat_found = false
	for cat in self.get_children(false):
		if not cat.is_in_group("Cat"): continue 
		if cat.cat_name == cat_stats["name"]:
			cat_found = true
			cat.create_cat(cat_stats)
	if not cat_found: add_cat_to_scene(cat_stats)
	pass
func delete_cat(cat_name):
	for cat in self.get_children(false):
		if not cat.is_in_group("Cat"): continue 
		if cat.cat_name == cat_name:
			cat.queue_free()
	
