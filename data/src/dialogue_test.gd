extends Control

@onready var background = $Background
@onready var character_left = $Characters/Left
@onready var character_center = $Characters/Center
@onready var character_right = $Characters/Right
@onready var image = $Image
@onready var dialogue = $Dialogue
@onready var dialogue_text = $Dialogue/Dialogue/Text
@onready var dialogue_character_name = $Dialogue/Name/RichTextLabel
@onready var choices = $Dialogue/Choices
@onready var choice_a = $Dialogue/Choices/ChoiceA
@onready var choice_b = $Dialogue/Choices/ChoiceB
@onready var choice_c = $Dialogue/Choices/ChoiceC
@onready var choice_d = $Dialogue/Choices/ChoiceD
@onready var effects = $Effects
@onready var effects_animation_player = $Effects/AnimationPlayer
@onready var gray_shader = preload("res://data/src/shaders/gray.gdshader")

var catalogs:Resource = preload("res://data/src/catalogs/catalogs.tres")

var sds_running:bool = false
var character_name:String = ""
var current_choices:Array = []

var dialogue_speed = 20
var tween_dialogue:Tween


func _ready():
	SDS.background_parsed.connect(_on_sds_background_parsed)
	SDS.bgm_parsed.connect(_on_sds_bgm_parsed)
	SDS.character_parsed.connect(_on_sds_character_parsed)
	SDS.choices_parsed.connect(_on_sds_choices_parsed)
	SDS.dialogue_parsed.connect(_on_sds_dialogue_parsed)
	SDS.dialogue_hide_parsed.connect(_on_sds_dialogue_hide_parsed)
	SDS.effect_parsed.connect(_on_sds_effect_parsed)
	SDS.end_parsed.connect(_on_sds_end_parsed)
	SDS.image_parsed.connect(_on_sds_image_parsed)
	SDS.name_parsed.connect(_on_sds_name_parsed)
	SDS.sfx_parsed.connect(_on_sds_sfx_parsed)
	Signals.sds_test.connect(hello_signal)
	Signals.game_over.connect(_on_game_over)

	tween_dialogue = get_tree().create_tween()
	tween_dialogue.connect("finished", _on_tween_dialogue_finished)

	effects.visible = false

	SDS.start_invoked.emit("res://data/dialogues/example.txt", "start")
	sds_running = true


func _process(delta):
	pass


func _on_sds_background_parsed(params:Dictionary):
	assert(params.id in catalogs.backgrounds, "Background id not found: " + JSON.stringify(params))

	assert(ResourceLoader.exists(catalogs.backgrounds[params.id]), "Cant load background texture: " + JSON.stringify(params))

	var background_texture = load(catalogs.backgrounds[params.id])
	background.texture = background_texture

	#effect?
	if params.effect != null:
		match params.effect:
			"gray":
				background.material = ShaderMaterial.new()
				background.material.shader  = gray_shader
				background.material.shader.resource_local_to_scene = true
				background.material.set_shader_parameter("gray", 4.0)
	else:
		background.material = null

	SDS.next_command_invoked.emit()


func _on_sds_bgm_parsed(params:Dictionary):
	if params.id == "STOP":
		Signals.stop_bgm.emit()
	else:
		assert(params.id in catalogs.bgm, "BGM id not found: " + JSON.stringify(params))
		assert(ResourceLoader.exists(catalogs.bgm[params.id]), "Cant load bgm file: " + JSON.stringify(params))

		Signals.play_bgm.emit(params.id)

	SDS.next_command_invoked.emit()


func _on_sds_character_parsed(params: Dictionary):
	var character_node = null

	match params.position:
		"left":
			character_node = character_left
		"center":
			character_node = character_center
		"right":
			character_node = character_right

	#hide character
	if params.id == "HIDE":
		if params.effect != null:
			character_node.get_node("AnimationPlayer").play(params.effect)

			if params.wait:
				await character_node.get_node("AnimationPlayer").animation_finished

		character_node.visible = false
		SDS.next_command_invoked.emit()
		return

	#show character
	assert(params.id in catalogs.characters, "Character id not found: " + JSON.stringify(params))

	var character_texture = load(catalogs.characters[params.id][params.expression])
	assert(character_texture, "Cant load character texture: " + JSON.stringify(params))

	character_node.visible = true
	character_node.texture = character_texture

	if params.effect != null:
		character_node.get_node("AnimationPlayer").play(params.effect)
		if params.wait:
			await character_node.get_node("AnimationPlayer").animation_finished

	SDS.next_command_invoked.emit()


func _on_sds_choices_parsed(params: Dictionary):
	choices.visible = true
	current_choices = params.choices

	choice_a.visible = false
	choice_b.visible = false
	choice_c.visible = false
	choice_d.visible = false

	if current_choices.size() >= 1:
		choice_a.visible = true
		choice_a.text = current_choices[0].choice

	if current_choices.size() >= 2:
		choice_b.visible = true
		choice_b.text = current_choices[1].choice

	if current_choices.size() >= 3:
		choice_c.visible = true
		choice_c.text = current_choices[2].choice

	if current_choices.size() >= 4:
		choice_d.visible = true
		choice_d.text = current_choices[3].choice


func _on_sds_dialogue_parsed(params:Dictionary):
	var character_count = params.text.length()

	dialogue.visible = true
	dialogue_text.visible = true
	dialogue_text.bbcode_text = params.text
	State.next_command_autofetch = params.autofetch

	if tween_dialogue:
		tween_dialogue.kill()

	tween_dialogue = get_tree().create_tween()
	tween_dialogue.tween_property(dialogue_text, "visible_characters", character_count, character_count / dialogue_speed).from(0)
	tween_dialogue.connect("finished", _on_tween_dialogue_finished)


func _on_sds_dialogue_hide_parsed():
	dialogue.visible = false
	dialogue_text.text = ""
	SDS.next_command_invoked.emit()


func _on_sds_end_parsed():
	sds_running = false


func _on_sds_effect_parsed(params:Dictionary):
	effects.visible = true

	match params.id:
		"fade_in":
			effects_animation_player.play("fade_in")
		"fade_out":
			effects_animation_player.play("fade_out")

	if params.wait:
		await effects_animation_player.animation_finished

	SDS.next_command_invoked.emit()


func _on_sds_image_parsed(params:Dictionary):
	if params.id == "HIDE":
		image.visible = false
		SDS.next_command_invoked.emit()
		return

	assert(params.id in catalogs.images, "Image id not found: " + JSON.stringify(params))
	assert(ResourceLoader.exists(catalogs.images[params.id]), "Cant load image texture: " + JSON.stringify(params))

	var image_texture = load(catalogs.images[params.id])
	image.texture = image_texture
	image.visible = true

	#effect?
	if params.effect != null:
		match params.effect:
			"gray":
				image.material = ShaderMaterial.new()
				image.material.shader  = gray_shader
				image.material.shader.resource_local_to_scene = true
				image.material.set_shader_parameter("gray", 4.0)

	SDS.next_command_invoked.emit()


func _on_sds_name_parsed(params:Dictionary):
	if params.name == "mc_name":
		character_name = State.mc_name
	else:
		character_name = params.name

	dialogue_character_name.text = character_name

	SDS.next_command_invoked.emit()

func _on_sds_sfx_parsed(params:Dictionary):
	assert(params.id in catalogs.sfx, "SFX id not found: " + JSON.stringify(params))
	assert(ResourceLoader.exists(catalogs.sfx[params.id]), "Cant load sfx file: " + JSON.stringify(params))

	Signals.play_sfx.emit(params.id)

	if params.wait:
		await Signals.play_sfx_finished

	SDS.next_command_invoked.emit()


func hello_signal(text):
	print("Hello signal " + text)


func _on_choice_button_up(choice_index):
	SDS.jump_parsed.emit(current_choices[choice_index].jump)
	choices.visible = false

func _on_tween_dialogue_finished():
	if State.next_command_autofetch:
		State.next_command_autofetch = false
		SDS.next_command_invoked.emit()

func _on_game_over():
	get_tree().quit()


func _input(event):
	if event is InputEventKey and event.is_action_pressed("ui_accept"):
		if sds_running:
			#if choosing, then do nothing
			if choices.visible:
				pass
			#are we showing dialogue?
			elif dialogue.visible:
				#not all text is shown... so show it, and stop tween
				if dialogue_text.visible_ratio < 1.0:
					dialogue_text.visible_ratio = 1.0

					if tween_dialogue.is_running():
						tween_dialogue.stop()

					#auto fetch next command if needed
					if State.next_command_autofetch:
						State.next_command_autofetch = false
						SDS.next_command_invoked.emit()
				#all text is shown.
				elif dialogue_text.visible_ratio >= 1.0:
					if State.next_command_autofetch:
						State.next_command_autofetch = false
					SDS.next_command_invoked.emit()


func _on_text_meta_clicked(meta):
	OS.shell_open(meta)
