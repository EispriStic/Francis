extends Control

#J'ai suivi ce tuto : 
# => https://www.youtube.com/watch?v=GzPvN5wsp7Y
 
var dialogPath = ""
export(float) var textSpeed = 0.05
 
var dialog
var phraseNum = 0
var finished = false
onready var box = $CanvasLayer/DialogBox
onready var timer = $CanvasLayer/DialogBox/Timer
onready var namelabel = $CanvasLayer/DialogBox/Name
onready var textlabel = $CanvasLayer/DialogBox/Text
onready var indicator = $CanvasLayer/DialogBox/Indicator
onready var portrait = $CanvasLayer/DialogBox/Portrait
onready var tree = get_tree()

func _ready():
	Globals.dialoging = get_parent() #Même soucis, voir func nextPhrase

func init(dialpath):
	yield(self, "ready")
	dialogPath = "res://Dialogs/dialog"+dialpath+".json"
	tree.paused = true
	timer.wait_time = textSpeed
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()
 
func _process(_delta):
	indicator.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			nextPhrase()
		else:
			textlabel.visible_characters = len(textlabel.text)
 
func getDialog() -> Array:
	var f = File.new()
	assert(f.file_exists(dialogPath), "File path does not exist")
	
	f.open(dialogPath, File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []
 
func nextPhrase() -> void:
	if phraseNum >= len(dialog):
		queue_free()
		
		get_tree().paused = false
		Globals.dialoging = null
		return
	
	finished = false
	
	namelabel.bbcode_text = dialog[phraseNum]["Name"]
	textlabel.bbcode_text = dialog[phraseNum]["Text"]
	
	textlabel.visible_characters = 0
	
	var f = File.new()
	var img = dialog[phraseNum]["Name"] + ".png"
	if f.file_exists("portraits/"+img):
		portrait.texture = load("portraits/"+img)
	else: portrait.texture = null
	
	while textlabel.visible_characters < len(textlabel.text):
		textlabel.visible_characters += 1
		
		timer.start()
		yield(timer, "timeout")
	
	finished = true
	phraseNum += 1
