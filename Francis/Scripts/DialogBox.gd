extends ColorRect

#J'ai suivi ce tuto : 
# => https://www.youtube.com/watch?v=GzPvN5wsp7Y
 
export var dialogPath = ""
export(float) var textSpeed = 0.05
 
var dialog
onready var tree = get_tree()
var phraseNum = 0
var finished = false

func _ready():
	Globals.dialoging = owner.get_parent() #Même soucis, voir func nextPhrase
	tree.paused = true
	$Timer.wait_time = textSpeed
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()
 
func _process(_delta):
	$Indicator.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			nextPhrase()
		else:
			$Text.visible_characters = len($Text.text)
 
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
		
		#La ligne qui pose problème ! :(
		
		#Le soucis c'est comment récupérer le "DialogNode" et son parent soit le npc
		#get_node("../../..").remove_child(get_node("../.."))
		
		#Edit : J'ai découvert "owner" c'est un peu moins moche, perso ça me parait logique.
		owner.get_parent().remove_child(owner)
		
		tree.paused = false
		Globals.dialoging = null
		return
	
	finished = false
	
	$Name.bbcode_text = dialog[phraseNum]["Name"]
	$Text.bbcode_text = dialog[phraseNum]["Text"]
	
	$Text.visible_characters = 0
	
	var f = File.new()
	var img = dialog[phraseNum]["Name"] + ".png"
	if f.file_exists("portraits/"+img):
		$Portrait.texture = load("portraits/"+img)
	else: $Portrait.texture = null
	
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		
		$Timer.start()
		yield($Timer, "timeout")
	
	finished = true
	phraseNum += 1
