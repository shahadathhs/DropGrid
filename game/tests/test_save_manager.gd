extends GutTest
## Save file format: version 1 to 2 migration, run recording, and sync flag handling.
## Each test uses its own temp file so the real save.json is never touched.

const TEST_PATH := "user://test_save_manager.json"

var _manager: SaveManager


func before_each() -> void:
	_remove_test_file()
	_manager = SaveManager.new()
	_manager.save_path = TEST_PATH


func after_each() -> void:
	_remove_test_file()


func _remove_test_file() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))


func _write_text(text: String) -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_v1_save_loads_and_new_fields_default_to_zero() -> void:
	_write_text('{"version": 1, "best_score": 1200, "sound_enabled": false}')
	_manager.load_data()
	assert_eq(_manager.best_score, 1200)
	assert_false(_manager.sound_enabled)
	assert_eq(_manager.total_lines, 0)
	assert_eq(_manager.games_played, 0)
	assert_false(_manager.pending_sync)


func test_saving_a_v1_file_writes_version_2() -> void:
	_write_text('{"version": 1, "best_score": 300}')
	_manager.load_data()
	_manager.save_data()
	var parsed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(TEST_PATH))
	assert_eq(int(parsed["version"]), 2)
	assert_eq(int(parsed["best_score"]), 300)
	assert_eq(int(parsed["games_played"]), 0)


func test_corrupt_file_starts_fresh() -> void:
	_write_text("this is not json {")
	_manager.load_data()
	assert_eq(_manager.best_score, 0)
	assert_true(_manager.sound_enabled)


func test_missing_file_starts_fresh() -> void:
	_manager.load_data()
	assert_eq(_manager.best_score, 0)
	assert_eq(_manager.games_played, 0)


func test_record_run_adds_stats_and_marks_pending() -> void:
	assert_true(_manager.record_run(500, 3), "first run sets a new best")
	assert_eq(_manager.best_score, 500)
	assert_eq(_manager.total_lines, 3)
	assert_eq(_manager.games_played, 1)
	assert_true(_manager.pending_sync)

	assert_false(_manager.record_run(200, 2), "a lower score does not beat the best")
	assert_eq(_manager.best_score, 500)
	assert_eq(_manager.total_lines, 5)
	assert_eq(_manager.games_played, 2)


func test_pending_sync_survives_a_reload() -> void:
	_manager.record_run(90, 1)
	var reloaded := SaveManager.new()
	reloaded.save_path = TEST_PATH
	reloaded.load_data()
	assert_true(reloaded.pending_sync)
	assert_eq(reloaded.total_lines, 1)


func test_mark_synced_keeps_pending_when_a_run_landed_mid_request() -> void:
	_manager.record_run(100, 1)
	var sent_revision := _manager.stats_revision
	_manager.record_run(50, 0)
	_manager.mark_synced(sent_revision)
	assert_true(_manager.pending_sync, "the newer run is still unsynced")

	_manager.mark_synced(_manager.stats_revision)
	assert_false(_manager.pending_sync)


func test_apply_merged_stats_writes_the_values() -> void:
	_manager.apply_merged_stats({"best_score": 900, "total_lines": 44, "games_played": 7})
	assert_eq(_manager.best_score, 900)
	assert_eq(_manager.total_lines, 44)
	assert_eq(_manager.games_played, 7)
