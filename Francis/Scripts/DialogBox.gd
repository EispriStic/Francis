extends Control
 
var dialogPath = ""
export(float) var textSpeed = 0.05
 
var dialog
var phraseNum = 0
var texting = false
var finished = false
onready var box = $CanvasLayer/DialogBox
onready var timer = $CanvasLayer/DialogBox/Timer
onready var namelabel = $CanvasLayer/DialogBox/Name
onready var textlabel = $CanvasLayer/DialogBox/Text
onready var indicator = $CanvasLayer/DialogBox/Indicator
onready var portrait = $CanvasLayer/DialogBox/Portrait
onready var choices = [$CanvasLayer/Choice1, $CanvasLayer/Choice2, $CanvasLayer/Choice3]
onready var tree = get_tree()

var dialog_id = null
var pnj_id = null
var indexes = {}
var changed_variable = null
var wait_for_choice = false

signal choosed

func _ready():
	Globals.dialoging = get_parent() #Même soucis, voir func nextPhrase

func init(id):
	yield(self, "ready")
	dialog_id = id
	for button in choices:
		button.visible = false
	dialogPath = "res://Dialogs/dialog"+str(dialog_id)+".json"
	tree.paused = true
	timer.wait_time = textSpeed
	dialog = getDialog()
	namelabel.bbcode_text = "???"
	indexing_dialog()
	assert(dialog, "Dialog not found")
	nextPhrase()
 
func _process(_delta):
	indicator.visible = finished and not wait_for_choice
	if texting:
		if Input.is_action_just_pressed("ui_accept"):
			if finished:
				nextPhrase()
			else:
				textlabel.visible_characters = len(textlabel.text)
	elif wait_for_choice:
		pass
	else:
		nextPhrase()
 
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
 
func indexing_dialog():
	for i in range(len(dialog)):
		if dialog[i].has("index"):
			indexes[str(dialog[i]["index"])] = i

func close_dialog():
	queue_free()
	get_tree().paused = false
	Globals.dialoging = null

func nextPhrase() -> void:
	print(Globals.known_npcs)
	if phraseNum >= len(dialog):
		close_dialog()
		return
	texting = false
	var line = dialog[phraseNum]
	match line:
		{"id", ..}:
			pnj_id = str(line["id"])
			if not Globals.known_npcs.has(pnj_id):
				Globals.known_npcs[pnj_id] = {"name":"???", "dialogs":{dialog_id:"0"}}
			else:
				var data = Globals.known_npcs[pnj_id]
				if not data["dialogs"].has(dialog_id):
					data["dialogs"][dialog_id] = "0"
				phraseNum = indexes[data["dialogs"][dialog_id]]
				namelabel.bbcode_text = data["name"].replace("PLAYER", Globals.pseudo).replace("KNOWN",Globals.known_npcs[pnj_id]["name"])
			continue
		{"save_index",..}:
			Globals.known_npcs[pnj_id]["dialogs"][dialog_id] = str(line["save_index"])
		{"image", ..}:
			var f = File.new()
			if f.file_exists("portraits/"+line["image"]+".png"):
				portrait.texture = load("portraits/"+line["image"]+".png")
			else: portrait.texture = null
			continue
		{"close_var", ..}:
			changed_variable = line["close_var"]
			continue
		{"name", ..}:
			if line["name"] == "PLAYER":
				namelabel.bbcode_text = Globals.pseudo
			elif line["name"] == "KNOWN":
				namelabel.bbcode_text = Globals.known_npcs[pnj_id]["name"]
			else:
				namelabel.bbcode_text = line["name"]
				Globals.known_npcs[pnj_id]["name"] = line["name"]
			continue
		{"choice", ..}:
			wait_for_choice = true
			for i in range(len(line["choice"])):
				choices[i].visible = true
				choices[i].text = line["choice"][i]
				choices[i].grab_focus()
			var choice = yield(self, "choosed")
			wait_for_choice = false
			phraseNum = indexes[str(line["indexes"][choice])]
			for button in choices:
				button.visible = false
			return
		{"close", ..}:
			close_dialog()
			var value = line["close"]
			if value != null and changed_variable != null:
				Globals[changed_variable] = value
		{"text", ..}:
			texting=true
			finished = false
			textlabel.visible_characters = 0
			textlabel.bbcode_text = line["text"].replace("PLAYER", Globals.pseudo).replace("KNOWN",Globals.known_npcs[pnj_id]["name"])
			
			while textlabel.visible_characters < len(textlabel.text):
				textlabel.visible_characters += 1
				timer.start()
				yield(timer, "timeout")
			finished = true
	phraseNum += 1

func _on_Choice1_pressed():
	emit_signal("choosed", 0)

func _on_Choice2_pressed():
	emit_signal("choosed", 1)

func _on_Choice3_pressed():
	emit_signal("choosed", 2)
