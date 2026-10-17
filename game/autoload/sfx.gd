extends Node
## Autoload singleton ("Sfx"): short sound effects routed to the SFX bus, muted
## via Save.sound_enabled. Original tones; see assets/audio/.

const SOUNDS := {
	"move": preload("res://assets/audio/move.wav"),
	"rotate": preload("res://assets/audio/rotate.wav"),
	"lock": preload("res://assets/audio/lock.wav"),
	"line_clear": preload("res://assets/audio/line_clear.wav"),
	"game_over": preload("res://assets/audio/game_over.wav"),
	"finish": preload("res://assets/audio/music/finish.wav"),
}

var _players: Array[AudioStreamPlayer] = []
var _next_player := 0


func _ready() -> void:
	# The SFX bus comes from res://default_bus_layout.tres. It must not be created in
	# code: on the web, buses added at runtime are mismatched in the browser's audio
	# graph and a mute on one lands on the master bus, silencing everything.
	# A small pool so overlapping sounds (e.g. two quick moves) don't cut off.
	for i in 4:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
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


## Applies the saved sound toggle to the bus. Called by the settings screen.
func update_buses() -> void:
	var index := AudioServer.get_bus_index("SFX")
	if index >= 0:
		AudioServer.set_bus_mute(index, not Save.sound_enabled)
