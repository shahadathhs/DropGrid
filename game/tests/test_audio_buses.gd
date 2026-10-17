extends GutTest
## The SFX and Music buses must come from the bus layout file, never from code:
## on the web, buses created at runtime are mismatched in the browser's audio graph
## and muting one silences the master bus (the game then makes no sound at all).

const LAYOUT_PATH := "res://default_bus_layout.tres"


func _apply_layout() -> void:
	var layout := load(LAYOUT_PATH) as AudioBusLayout
	assert_not_null(layout, "%s must exist" % LAYOUT_PATH)
	AudioServer.set_bus_layout(layout)


func test_layout_file_defines_the_sfx_and_music_buses() -> void:
	_apply_layout()
	assert_eq(AudioServer.bus_count, 3, "Master, SFX, Music")
	assert_eq(AudioServer.get_bus_name(1), "SFX")
	assert_eq(AudioServer.get_bus_name(2), "Music")
	assert_eq(AudioServer.get_bus_send(1), &"Master")
	assert_eq(AudioServer.get_bus_send(2), &"Master")


func test_buses_start_unmuted_so_the_settings_decide() -> void:
	_apply_layout()
	for index in AudioServer.bus_count:
		assert_false(AudioServer.is_bus_mute(index), "bus %d starts unmuted" % index)
