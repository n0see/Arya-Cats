extends Node2D
# To Add :
# Cat up and down
# Cat personality
# more cats 
# fix movment
var defualt = {
	"body_color": "#FF5733",
	"name": "W3R",
	"pattern_color": "#C70039",
	"bounds" : Vector2(0,200)
}
enum CatState {
	IDLE,
	MOVING,
	SITTING,
	LAYING_DOWN,
	RUNNING,
	SLEEPING,
	STANDING,
	VOCALIZING
}

#var sleep_levels_left = ['SleepLF','Sleep2LF','Sleep3LF','Sleep4LF','Sleep5LF']
#var sleep_levels_right = ['SleepRF','Sleep2RF','Sleep3RF','Sleep4RF','Sleep5RF']

@onready var animation_player = $AnimationPlayer
var paused = false
var current_state = CatState.IDLE
var current_flip_side = 'LF'
var last_sleep_side = "LF" # "LF" or "RF"
var last_walking_side = "LF"
var last_walking_speed = "Walk"
var sleep_level = 1
var time_since_last_sleep = 15
var time_in_current_state = 0.0
var speed = 0 
const SLEEP_COOLDOWN = 60.0
var bounds = Vector2(0,200)
var cat_name = "default"

var sitting_animations = ["LickPawSitFront", "Meowsitfront", "ScratchSitLeft", "ScratchSitRight", "TailWagSitFront", "RightPawSwipeSit", "LeftPawSwipeSit", "YawnSit", "OnhindLegs"]
var Laying_down_animations = ['LickPawLieFrontLF','MeowliefrontLF','TailWagLieLF']
var standing_animations = ['MeowStandFront','TailWagStandFront','RightPawSwipe','LeftPawSwipe']



func _ready():
	# Set a random start animation
	play_random_sitting_animation()
	current_state = CatState.SITTING

func _process(delta):
	if paused :
		return
	time_in_current_state += delta
	time_since_last_sleep += delta # Increment the cooldown timer
	position.x = position.x + (speed*delta)

	match current_state:
		CatState.SITTING:
			if time_in_current_state > randf_range(5.0, 10.0): # Random time to prevent predictability
				if randf() < 0.4:
					change_state(CatState.LAYING_DOWN)
				elif randf() < 0.5:
					change_state(CatState.STANDING)
				else:
					play_random_sitting_animation()
					time_in_current_state = 0.0

		CatState.LAYING_DOWN:
			if time_in_current_state > randf_range(5.0, 10.0):
				# Check the cooldown before allowing the transition to SLEEPING
				if time_since_last_sleep >= SLEEP_COOLDOWN:
					# The cat is allowed to sleep now
					if randf() < 0.8:
						change_state(CatState.SLEEPING) 
					else:
						change_state(CatState.SITTING)
				else:
					# The cooldown is not over, so the cat CANNOT go to sleep.
					# Do a different random action instead.
					if randf() < 0.7:
						play_random_laying_animation()
					change_state(CatState.SITTING) # For example, transition to sitting
		CatState.SLEEPING:
			# Check if it's time to increment sleep level
			if time_in_current_state > 5.0 and sleep_level < 5:
				sleep_level += 1
				play_animation("Sleep" + str(sleep_level) + last_sleep_side)
				time_in_current_state = 0.0
			
			# Check if it's time to wake up
			if sleep_level == 5 and time_in_current_state > randf_range(30.0, 60.0):
				change_state(CatState.LAYING_DOWN) # Cat wakes up into a laying state
				sleep_level = 1
			elif sleep_level < 5 and time_in_current_state > randf_range(15.0, 25.0):
				if randf() < 0.2: # Small chance of waking up from light sleep
					change_state(CatState.LAYING_DOWN)
					
		CatState.STANDING:
			if time_in_current_state > randf_range(5.0, 10.0): # Random time to prevent predictability
				if randf() < 0.4:
					change_state(CatState.SITTING)
				elif randf() < 0.6:
					change_state(CatState.MOVING)
				else:
					play_random_standing_animation()
					time_in_current_state = 0.0
		CatState.MOVING:
			if time_in_current_state > randf_range(5.0, 10.0):
				if randf() < 0.6: 
					change_state(CatState.STANDING)
					speed = 0
				else:
					speed = 0 
					change_state(CatState.MOVING)

func change_state(new_state):
	if current_state == CatState.SLEEPING:
		time_since_last_sleep = 0.0 # Reset the cooldown timer

	current_state = new_state
	time_in_current_state = 0.0
	
	match new_state:
		CatState.SITTING:
			play_random_sitting_animation()
		CatState.LAYING_DOWN:
			play_random_laying_animation() # Or a different 'start' laying animation
			if randf() < 0.5:
				last_sleep_side = "LF"
			else:
				last_sleep_side = "RF"
		CatState.STANDING:
			play_random_standing_animation()
		CatState.SLEEPING:
			# Randomly pick a starting sleep side if it's the first time
			sleep_level = 1
			play_animation("Sleep" + str(sleep_level) + last_sleep_side)
		CatState.MOVING:
			movement_animation_handler()
			
func play_animation(anim_name):
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
		return true
	else:
		print("Error: Animation not found: ", anim_name)
		return false

func play_random_sitting_animation():
	var anim = sitting_animations[randi() % sitting_animations.size()]
	play_animation(anim)
func play_random_laying_animation():
	var anim = Laying_down_animations[randi() % Laying_down_animations.size()]
	if play_animation(anim):
		if last_sleep_side != current_flip_side:
			self.scale.x = scale.x *-1
			$Control.scale.x = scale.x *-1
			if current_flip_side == 'LF':
				current_flip_side = 'RF'
			else: 
				current_flip_side = 'LF'
func play_random_standing_animation():
	var anim = standing_animations[randi() % standing_animations.size()]
	play_animation(anim)
func movement_animation_handler(): #
	#choose a diraction
	if randf_range(bounds.x,bounds.y) > self.position.x:
		last_walking_side = 'RF'
	else:
		last_walking_side = 'LF'
	#choose a speed
	if randf() < 0.5 :
		last_walking_speed = "Walk"
	else:
		last_walking_speed = "Run"
	#play animation accordingly
	play_animation(last_walking_speed+last_walking_side)
	#reset flip side
	if current_flip_side == "RF":
		self.scale.x = scale.x *-1
		$Control.scale.x = scale.x *-1
		current_flip_side = 'LF'
	handle_momvment()
	
func handle_momvment():
	if last_walking_speed == 'Walk':
		speed = 10
	else:
		speed = 25
	if last_walking_side == 'RF':
		speed = speed
	else: 
		speed = speed*-1
	pass

# ... you would have many more of these helper functions
func set_color(color_name, color):
	match color_name:
		"Body":
			$Body.self_modulate = color
		"Pattern":
			$Pattern.self_modulate = color
func set_bounding_box(box):
	bounds = box
func _set_name(catname):
	cat_name = catname
	$Control/Label.text = catname
func _input(event):
	if paused : return
	if event.is_action_pressed("ui_down"):
		change_state(CatState.MOVING)
			# Initiate a jump
		pass

func create_cat(stats):
	set_color("Body",stats["body_color"])
	set_color("Pattern",stats["pattern_color"])
	set_bounding_box(stats["bounds"])
	_set_name(stats["name"])
	pass

func _on_control_mouse_entered() -> void:
	if paused : return
	$Control/Label.visible = true
	pass # Replace with function body.


func _on_control_mouse_exited() -> void:
	if paused : return
	$Control/Label.visible = false
	pass # Replace with function body.
