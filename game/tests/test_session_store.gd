extends GutTest
## Session file: round trip, missing and corrupt files, and sign-out clearing.

const TEST_PATH := "user://test_session_store.json"


func before_each() -> void:
	SessionStore.clear_session(TEST_PATH)


func after_each() -> void:
	SessionStore.clear_session(TEST_PATH)


func test_missing_file_means_no_session() -> void:
	assert_eq(SessionStore.load_session(TEST_PATH), {})


func test_saved_session_loads_back() -> void:
	var session := {
		"access_token": "a1",
		"refresh_token": "r1",
		"username": "rejoan",
		"email": "p@example.com",
	}
	assert_true(SessionStore.save_session(session, TEST_PATH))
	assert_eq(SessionStore.load_session(TEST_PATH), session)


func test_corrupt_file_means_no_session() -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string("[1, 2, 3")
	file.close()
	assert_eq(SessionStore.load_session(TEST_PATH), {})


func test_file_without_an_access_token_means_no_session() -> void:
	SessionStore.save_session({"refresh_token": "r1"}, TEST_PATH)
	assert_eq(SessionStore.load_session(TEST_PATH), {})


func test_clear_removes_the_file() -> void:
	SessionStore.save_session({"access_token": "a1"}, TEST_PATH)
	SessionStore.clear_session(TEST_PATH)
	assert_false(FileAccess.file_exists(TEST_PATH))
