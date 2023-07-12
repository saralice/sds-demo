extends Node

@onready var bgm_player:AudioStreamPlayer = $BgmPlayer
@onready var sfx_player:AudioStreamPlayer = $SfxPlayer

var catalogs:Resource = preload("res://data/src/catalogs/catalogs.tres")

var current_bgm = ""

func _ready():
	Signals.play_bgm.connect(_on_play_bgm)
	Signals.stop_bgm.connect(_on_stop_bgm)
	Signals.play_sfx.connect(_on_play_sfx)

func play_bgm(bgm:String) -> void:
	var allow_play = false

	if current_bgm != bgm: #different song
		stop_bgm()
		allow_play = true
	elif current_bgm != "" and not bgm_is_playing(): #same song was stopped, allow play
		allow_play = true

	if allow_play:
		current_bgm = bgm
		var stream:AudioStreamOggVorbis = load(catalogs.bgm[bgm])
		stream.loop = true
		bgm_player.stream = stream
		bgm_player.play()


func play_sfx(sfx:String) -> void:
	var stream:AudioStreamOggVorbis = load(catalogs.sfx[sfx])
	stream.loop = false
	sfx_player.stream = stream
	sfx_player.play()

func bgm_is_playing() -> bool:
	return bgm_player.is_playing()

func _on_play_bgm(file:String) -> void:
	play_bgm(file)

func _on_play_sfx(file:String) -> void:
	play_sfx(file)

func stop_bgm():
	if bgm_player.is_playing():
		bgm_player.stop()

func _on_sfx_player_finished():
	Signals.play_sfx_finished.emit()

func _on_stop_bgm():
	stop_bgm()

