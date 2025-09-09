extends Control

@onready var Cat = $cat
const SAVE_PATH = "res://Saves/cats.json"
var mini_cat_scene = preload("res://Scenes/catmainmenu.tscn")
const CAT_NAMES = [
	"Poppy", "Bella", "Misty", "Molly", "Daisy", "Tilly", "Luna", "Lily",
	"Lilly", "Willow", "Coco", "Betty", "Missy", "Sophie", "Belle", "Cleo",
	"Izzy", "Hana", "Mika", "Charlie", "Felix", "Finley", "Buddy", "Ralph",
	"Oscar", "Milo", "George", "Tigger", "Alfie", "Jasper", "Max", "Tiger",
	"Simba", "Bob", "Casper", "Fred", "Freddie", "Tommy", "Gizmo", "Harry",
	"Oliver", "Joey", "Drake", "Bello", "Pumpkin", "Smudge", "Boo", "Bubbles",
	"Fudge", "Fluffy", "Fuzzy", "Patches", "Tabby", "Socks", "Marbles", "Lucky",
	"Inky", "Spot", "Brownie", "Oreo", "Fliss", "Max", "Buster", "Rosie",
	"Millie", "Tia", "Shadow", "Bear", "Holly", "Lucy", "Sasha", "Ruby",
	"Bruno", "Marley", "Toby", "Scuttlebutt", "Jigglypuff", "Zuzu", "Marmite",
	"Major Tom", "Mertle", "Rebel", "Cocoa", "Welly Boots", "Twinkle Toes",
	"Harriet Potter", "Slinky Malinki", "Fish Biscuit", "Chewbacca",
	"Miss Badger", "Europe", "Nemo", "Vardy", "Mojito", "Spartapuss",
	"Tilly Pig", "Jalapeno", "Pinto", "McCool", "Bam Bam", "Shebee"
]
var body_color
var pattern_color
var rng = RandomNumberGenerator.new()
func _ready():
	Cat.paused = true
	Cat.play_animation("WalkLF")
	Cat.set_color("Body",$VBoxContainer/HBoxContainer/BodyColorPickerButton.color)
	Cat.set_color("Pattern",$VBoxContainer/HBoxContainer2/PatternColorPickerButton.color)
	make_cats_menu()
	rng.randomize()


func _on_body_color_picker_button_color_changed(color: Color) -> void:
	Cat.set_color("Body",color)
	pass # Replace with function body.


func _on_pattern_color_picker_button_color_changed(color: Color) -> void:
	Cat.set_color("Pattern",color)
	pass # Replace with function body.


func _on_delete_pressed() -> void:
	_on_DeleteButton_pressed()
	refresh_cats_menu()
	pass # Replace with function body.


func _on_save_pressed() -> void:
	_on_SaveButton_pressed()
	refresh_cats_menu()
	pass # Replace with function body.

# A handy function to load the cat data
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

# A handy function to save the cat data
func save_cats(cats_array):
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		print("Failed to open file for writing.")
		return false

	var json_string = JSON.stringify(cats_array, "\t")
	file.store_string(json_string)
	return true

# --- Save Button Logic ---
func _on_SaveButton_pressed():
	var catname = $HBoxContainer3/TextEdit.text
	if catname == "":
		print("Name cannot be empty!")
		return
		
	body_color = $VBoxContainer/HBoxContainer/BodyColorPickerButton.color
	pattern_color = $VBoxContainer/HBoxContainer2/PatternColorPickerButton.color
	
	# Create the new cat dictionary
	var new_cat_data = {
		"name": catname,
		"body_color": body_color.to_html(false),  # Convert to a hex string
		"pattern_color": pattern_color.to_html(false)
	}

	var cats = load_cats()
	var cat_exists = false
	
	# Check if a cat with the same name already exists
	for i in range(cats.size()):
		if cats[i]["name"] == catname:
			# Found an existing cat, so edit it
			cats[i] = new_cat_data
			cat_exists = true
			print("Cat '", catname, "' updated.")
			break
			
	if not cat_exists:
		# No existing cat found, so add a new one
		cats.append(new_cat_data)
		print("New cat '", catname, "' saved.")
		
	save_cats(cats)

# --- Delete Button Logic ---
func _on_DeleteButton_pressed():
	var name_to_delete = $HBoxContainer3/TextEdit.text
	if name_to_delete == "" :
		print("Name cannot be empty for deletion!")
		return

	var cats = load_cats()
	var original_size = cats.size()
	
	# Filter the array to create a new array without the cat to delete
	# This is an efficient way to remove an element
	var filtered_cats = []
	for cat in cats:
		if cat["name"] != name_to_delete:
			filtered_cats.append(cat)
			
	if original_size == filtered_cats.size():
		print("Cat '", name_to_delete, "' not found.")
		return
		
	save_cats(filtered_cats)
	print("Cat '", name_to_delete, "' deleted.")

func change_main_cat(newname, new_b_color, new_p_color):
	Cat.play_animation("WalkLF")
	$HBoxContainer3/TextEdit.text = newname
	Cat.set_color("Body",new_b_color)
	Cat.set_color("Pattern",new_p_color)
	$VBoxContainer/HBoxContainer/BodyColorPickerButton.color = new_b_color
	$VBoxContainer/HBoxContainer2/PatternColorPickerButton.color = new_p_color
	
func make_cats_menu():
	var cats = load_cats()
	print(cats)
	for cat in cats  :
		var newcat = mini_cat_scene.instantiate()
		print('added a new cat : ',cat)
		newcat.set_cat(cat["name"], cat["body_color"], cat["pattern_color"])
		$ScrollContainer/GridContainer.add_child(newcat)
		var panelnode = newcat.get_node("Panel")
		if panelnode:
			panelnode.gui_input.connect(Callable(self, "_on_panel_gui_input").bind(cat))
			print("Signal connected successfully!")
		else:
			print("Error: Panel node not found in the instantiated scene.")
		
func refresh_cats_menu(): 
	for cat in $ScrollContainer/GridContainer.get_children():
		cat.queue_free()
	make_cats_menu()
	

func _get_random_cat_name() -> String:
	var random_index = rng.randi_range(0, CAT_NAMES.size() - 1)
	return CAT_NAMES[random_index]
	
func _get_random_color():
	var r = randf()
	var g = randf()
	var b = randf()
	return Color(r, g, b)
func _on_panel_gui_input(event,cat):
	# This function is the signal handler!
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				change_main_cat(cat["name"], cat["body_color"], cat["pattern_color"])
				print("Panel was clicked at: ", event.position)


func _on_random_pressed() -> void:
	change_main_cat(_get_random_cat_name(), _get_random_color(), _get_random_color())
	pass # Replace with function body.
