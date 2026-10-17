extends GutTest
## The rule that decides whether a music loop is audible.


func test_plays_when_enabled_and_the_track_exists() -> void:
	assert_true(Music.should_play(true, "gameplay"))
	assert_true(Music.should_play(true, "menu"))
	assert_true(Music.should_play(true, "zen"))


func test_silent_when_disabled_whatever_the_track() -> void:
	assert_false(Music.should_play(false, "gameplay"))
	assert_false(Music.should_play(false, "zen"))


func test_silent_without_a_track() -> void:
	assert_false(Music.should_play(true, ""))
	assert_false(Music.should_play(true, "no_such_track"))
