extends GutTest
## Pure sync helpers: stat merge, retry delays, error text, and input checks.


func test_merge_takes_the_max_of_each_stat() -> void:
	var local := {"best_score": 1200, "total_lines": 40, "games_played": 9}
	var server := {"best_score": 800, "total_lines": 55, "games_played": 3}
	var merged := SyncLogic.merge_stats(local, server)
	assert_eq(merged, {"best_score": 1200, "total_lines": 55, "games_played": 9})


func test_a_lower_server_value_never_overwrites_local() -> void:
	# A fresh account has zeros on the server; local progress must survive the merge.
	var local := {"best_score": 500, "total_lines": 12, "games_played": 4}
	var server := {"best_score": 0, "total_lines": 0, "games_played": 0}
	assert_eq(SyncLogic.merge_stats(local, server), local)


func test_missing_fields_count_as_zero() -> void:
	var merged := SyncLogic.merge_stats({"best_score": 70}, {"games_played": 2})
	assert_eq(merged, {"best_score": 70, "total_lines": 0, "games_played": 2})


func test_backoff_starts_at_five_seconds_and_doubles() -> void:
	assert_eq(SyncLogic.backoff_delay(1), 5.0)
	assert_eq(SyncLogic.backoff_delay(2), 10.0)
	assert_eq(SyncLogic.backoff_delay(3), 20.0)
	assert_eq(SyncLogic.backoff_delay(4), 40.0)


func test_backoff_is_capped_at_five_minutes() -> void:
	assert_eq(SyncLogic.backoff_delay(6), 160.0)
	assert_eq(SyncLogic.backoff_delay(7), 300.0, "5 * 2^6 = 320 must be capped to 300")
	assert_eq(SyncLogic.backoff_delay(50), 300.0)


func test_no_failures_means_no_delay() -> void:
	assert_eq(SyncLogic.backoff_delay(0), 0.0)


func test_network_and_server_errors_are_retryable_but_client_errors_are_not() -> void:
	assert_true(SyncLogic.is_retryable(0))
	assert_true(SyncLogic.is_retryable(503))
	assert_false(SyncLogic.is_retryable(401))
	assert_false(SyncLogic.is_retryable(409))


func test_error_message_prefers_the_server_detail() -> void:
	assert_eq(SyncLogic.error_message(409, {"detail": "Username taken"}), "Username taken")


func test_error_message_has_a_fallback_without_detail() -> void:
	assert_eq(SyncLogic.error_message(0, {}), "Couldn't reach the server. Try again later.")


func test_username_length_limits() -> void:
	assert_false(SyncLogic.is_valid_username("ab"))
	assert_true(SyncLogic.is_valid_username("abc"))
	assert_true(SyncLogic.is_valid_username("a".repeat(20)))
	assert_false(SyncLogic.is_valid_username("a".repeat(21)))


func test_email_needs_an_at_and_a_dot_after_it() -> void:
	assert_true(SyncLogic.is_valid_email("player@example.com"))
	assert_false(SyncLogic.is_valid_email("player.example.com"))
	assert_false(SyncLogic.is_valid_email("@example.com"))
	assert_false(SyncLogic.is_valid_email("player@example."))


func test_password_has_a_minimum_length() -> void:
	assert_false(SyncLogic.is_valid_password("1234567"))
	assert_true(SyncLogic.is_valid_password("12345678"))


func test_empty_api_url_disables_online_features() -> void:
	assert_false(SyncLogic.is_online_enabled(""))
	assert_false(SyncLogic.is_online_enabled("   "))
	assert_true(SyncLogic.is_online_enabled("https://api.example.com/v1"))
