extends Control

var catname = ""
var bodycolor = "color"
var patcolor = "color"

func _ready():
	$PanelContainer/cat.paused = true
	$PanelContainer/cat.play_animation("WalkLF")
	$PanelContainer/cat.find_child("AnimationPlayer").pause()

func set_cat(newname,newbcolor,newpcolor):
	catname = newname
	bodycolor = newbcolor
	patcolor = newpcolor
	$PanelContainer/cat.set_color("Body",bodycolor)
	$PanelContainer/cat.set_color("Pattern",patcolor)
	$PanelContainer/Label.text = catname
