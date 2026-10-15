extends GutTest
## Guest play must never touch the network. A Sync instance with no session
## should queue nothing when the game asks it to push stats.

const SESSION_PATH := "user://test_guest_sync_session.json"

var _sync


func before_each() -> void:
	SessionStore.clear_session(SESSION_PATH)
	_sync = preload("res://autoload/sync.gd").new()
	_sync.session_path = SESSION_PATH
	add_child_autofree(_sync)


func after_each() -> void:
	SessionStore.clear_session(SESSION_PATH)


func test_guest_is_not_signed_in() -> void:
	assert_false(_sync.is_signed_in())


func test_guest_push_stats_queues_no_request() -> void:
	_sync.push_stats()
	assert_eq(_sync.queued_request_count(), 0)


func test_guest_profile_fetch_queues_no_request() -> void:
	_sync.fetch_profile()
	assert_eq(_sync.queued_request_count(), 0)


func test_guest_rename_fails_locally_without_a_request() -> void:
	_sync.rename("newname")
	assert_eq(_sync.queued_request_count(), 0)


func test_default_build_has_an_api_url() -> void:
	assert_true(_sync.is_online_enabled())
