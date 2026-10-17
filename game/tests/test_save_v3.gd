extends GutTest
## Save version 3: the new settings and the per-category bests, plus the
## category merge used when the server answers a sync.

const TEST_PATH := "user://test_save_v3.json"


func _manager() -> SaveManager:
	var manager := SaveManager.new()
	manager.save_path = TEST_PATH
	return manager


func after_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)


func test_new_settings_round_trip_through_the_save_file() -> void:
	var manager := _manager()
	manager.load_data()
	manager.set_music_enabled(false)
	manager.set_ground_light(true)
	manager.set_ghost_enabled(false)
	manager.set_left_handed(true)
	manager.set_large_buttons(true)

	var reloaded := _manager()
	reloaded.load_data()
	assert_false(reloaded.music_enabled)
	assert_true(reloaded.ground_light)
	assert_false(reloaded.ghost_enabled)
	assert_true(reloaded.left_handed)
	assert_true(reloaded.large_buttons)
	assert_eq(reloaded.best_score, 0, "settings changes must not create a best score")


func test_score_categories_take_the_higher_score() -> void:
	var manager := _manager()
	assert_true(manager.record_category_run("marathon", {"score": 500, "lines": 4}))
	assert_false(manager.record_category_run("marathon", {"score": 400, "lines": 4}))
	assert_true(manager.record_category_run("marathon", {"score": 900, "lines": 8}))
	assert_eq(manager.counting_best("marathon")["score"], 900)


func test_sprint_takes_the_lower_duration() -> void:
	var manager := _manager()
	assert_true(manager.record_category_run("sprint", {"duration_ms": 95_000, "lines": 40}))
	assert_false(manager.record_category_run("sprint", {"duration_ms": 96_000, "lines": 40}))
	assert_true(manager.record_category_run("sprint", {"duration_ms": 61_000, "lines": 40}))
	assert_eq(manager.counting_best("sprint")["duration_ms"], 61_000)


func test_expired_daily_bests_stop_counting() -> void:
	var manager := _manager()
	var payload := {"score": 700, "lines": 3, "date": "1999-01-01"}
	manager.category_bests["daily"] = payload
	assert_eq(manager.counting_best("daily"), {}, "a daily best from 1999 counts no more")
	assert_false(manager.record_category_run("daily", {"score": 100, "lines": 1}))


func test_daily_records_are_stamped_with_the_utc_date() -> void:
	var manager := _manager()
	assert_true(manager.record_category_run("daily", {"score": 700, "lines": 3}))
	var best := manager.counting_best("daily")
	assert_eq(str(best["date"]), GameMode.daily_date())
	assert_eq(int(best["score"]), 700)


func test_unknown_categories_are_rejected() -> void:
	var manager := _manager()
	assert_false(manager.record_category_run("zen", {"score": 10, "lines": 1}))
	assert_false(manager.record_category_run("prestige", {"score": 10, "lines": 1}))


func test_merge_category_bests_takes_higher_scores_and_faster_sprints() -> void:
	var local := {
		"marathon": {"score": 500, "lines": 4},
		"sprint": {"duration_ms": 61_000, "lines": 40},
	}
	var server := {
		"marathon": {"score": 1_200, "lines": 9},
		"sprint": {"duration_ms": 63_000, "lines": 40},
		"ultra": {"score": 300, "lines": 2},
	}
	var merged := SyncLogic.merge_category_bests(local, server)
	assert_eq(int(merged["marathon"]["score"]), 1_200)
	assert_eq(int(merged["sprint"]["duration_ms"]), 61_000)
	assert_eq(int(merged["ultra"]["score"]), 300)


func test_merge_daily_bests_prefer_the_newer_date() -> void:
	var local := {"daily": {"score": 900, "lines": 5, "date": "2026-10-17"}}
	var newer := {"daily": {"score": 100, "lines": 1, "date": "2026-10-18"}}
	assert_eq(
		int(SyncLogic.merge_category_bests(local, newer)["daily"]["score"]),
		100,
		"an empty newer day beats an old score"
	)
	var older := {"daily": {"score": 50, "lines": 1, "date": "2026-10-16"}}
	assert_eq(
		int(SyncLogic.merge_category_bests(local, older)["daily"]["score"]),
		900,
		"an older day must not replace today's score"
	)


func test_version_two_files_gain_version_three_defaults() -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string('{"version": 2, "best_score": 42, "sound_enabled": true}')
	file.close()
	var reloaded := _manager()
	reloaded.load_data()
	assert_eq(reloaded.best_score, 42)
	assert_false(reloaded.music_enabled, "music defaults to off when the field is missing")
	assert_eq(reloaded.category_bests, {})
	reloaded.set_music_enabled(false)  # saving writes the full v3 dictionary
	var raw: Variant = JSON.parse_string(FileAccess.open(TEST_PATH, FileAccess.READ).get_as_text())
	assert_eq(int(raw["version"]), 3)
