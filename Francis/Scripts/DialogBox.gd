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

var indexes = {}
var id
var npc
var changed_variable = null
var wait_for_choice = false

signal choosed

func _ready():
	Globals.dialoging = get_parent() #Même soucis, voir func nextPhrase

func init(id):
	yield(self, "ready")
	for button in choices:
		button.visible = false
	dialogPath = "res://Dialogs/dialog"+str(id)+".json"
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
			var id = str(dialog[i]["index"])
			indexes[id] = i

func goto(index):
	phraseNum = indexes[str(index)]

func format_string(string):
	return string.replace("PLAYER", Globals.pseudo).replace("KNOWN",npc["name"])

func close_dialog():
	queue_free()
	get_tree().paused = false
	Globals.dialoging = null

func nextPhrase() -> void:
	if phraseNum >= len(dialog):
		close_dialog()
		return
	texting = false
	var line = dialog[phraseNum]
	match line:
		{"id", ..}:
			id = str(line["id"])
			if Globals.dialog_data.has(id):
				goto(Globals.dialog_data[id])
			else:
				Globals.dialog_data[id] = "0"
		{"goto", ..}:
			goto(line["goto"])
		{"save_index",..}:
			Globals.dialog_data[id] = str(line["save_index"])
		{"npc", ..}:
			var origin_name = line["npc"]
			if not Globals.find_npc_by_name(origin_name):
				Globals.npc_known.append({"name":"???", "origin_name":origin_name})
			npc = Globals.find_npc_by_name(origin_name)
			
			var f = File.new()
			if f.file_exists("portraits/"+origin_name+".png"):
				portrait.texture = load("portraits/"+origin_name+".png")
			else: portrait.texture = null
			
			namelabel.bbcode_text = format_string(npc["name"])
		{"close_var", ..}:
			changed_variable = line["close_var"]
		{"name", ..}:
			if line["name"] != npc["name"]:
				npc["name"] = line["name"]
			namelabel.bbcode_text = format_string(npc["name"])
		{"choice", ..}:
			wait_for_choice = true
			for i in range(len(line["choice"])):
				choices[i].visible = true
				choices[i].text = line["choice"][i]
				choices[i].grab_focus()
			if len(line["choice"]) == 3:
				$CanvasLayer/Choice1.focus_neighbour_bottom = $CanvasLayer/Choice3.get_path()
				$CanvasLayer/Choice2.focus_neighbour_top = $CanvasLayer/Choice3.get_path()
			else:
				$CanvasLayer/Choice1.focus_neighbour_bottom = $CanvasLayer/Choice2.get_path()
				$CanvasLayer/Choice2.focus_neighbour_top = $CanvasLayer/Choice1.get_path()
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
			textlabel.bbcode_text = format_string(line["text"])
			
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
