extends Node
## Autoload singleton ("Sfx"): short sound effects, muted via Save.sound_enabled.
## Original tones generated for this project; see assets/audio/.

const SOUNDS := {
	"move": preload("res://assets/audio/move.wav"),
	"rotate": preload("res://assets/audio/rotate.wav"),
	"lock": preload("res://assets/audio/lock.wav"),
	"line_clear": preload("res://assets/audio/line_clear.wav"),
	"game_over": preload("res://assets/audio/game_over.wav"),
}

var _players: Array[AudioStreamPlayer] = []
var _next_player := 0


func _ready() -> void:
	# A small pool so overlapping sounds (e.g. two quick moves) don't cut off.
	for i in 4:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players.append(player)


func play(sound_name: String) -> void:
	if not Save.sound_enabled:
		return
	var stream: AudioStream = SOUNDS.get(sound_name)
	if stream == null:
		return
	var player := _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = stream
	player.play()
