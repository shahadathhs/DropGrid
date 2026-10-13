extends GutTest
## Haptics: vibrate only when the setting is on and the device is a phone.

const GameScript := preload("res://scripts/game.gd")


func test_vibrates_on_android_and_ios_when_enabled() -> void:
	assert_true(GameScript.should_vibrate(true, "Android"))
	assert_true(GameScript.should_vibrate(true, "iOS"))


func test_never_vibrates_when_haptics_is_off() -> void:
	assert_false(GameScript.should_vibrate(false, "Android"))
	assert_false(GameScript.should_vibrate(false, "iOS"))


func test_never_vibrates_on_desktop_or_web() -> void:
	assert_false(GameScript.should_vibrate(true, "macOS"))
	assert_false(GameScript.should_vibrate(true, "Windows"))
	assert_false(GameScript.should_vibrate(true, "Linux"))
	assert_false(GameScript.should_vibrate(true, "Web"))
