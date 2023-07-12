extends Resource
class_name Catalogs

var backgrounds:Dictionary = {
	"city": "res://data/backgrounds/city.jpg",
	"park": "res://data/backgrounds/park.jpg"
}

var characters:Dictionary = {
	"bro" : {
		"laugh": "res://data/characters/bro/laugh.png",
		"smile": "res://data/characters/bro/smile.png",
		"surprised": "res://data/characters/bro/surprised.png",
	},
	"saralice" : {
		"sad": "res://data/characters/saralice/sad.png",
		"smile": "res://data/characters/saralice/smile.png",
		"smug": "res://data/characters/saralice/smug.png",
	},
}

var images:Dictionary = {
	"rubber_duck": "res://img/pictures/rubber_duck.jpeg",
	"if_example": "res://img/pictures/if_example.png"
}

var bgm:Dictionary = {
	"city": "res://audio/bgm/Alexander Ehlers - Warped.ogg",
}

var sfx:Dictionary = {
	"cellphone_ring": "res://audio/sfx/zapsplat_technology_cb_radio_call_ring_39800.ogg"
}
