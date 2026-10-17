class_name UiFormat
extends RefCounted
## Text helpers for the screens.


## Formats a number with commas every three digits, for example 18460 -> "18,460".
static func thousands(value: int) -> String:
	var digits := str(absi(value))
	var result := ""
	var count := 0
	for i in range(digits.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = digits[i] + result
		count += 1
	return "-" + result if value < 0 else result


## Formats milliseconds as m:ss, for example 83000 -> "1:23".
static func clock(ms: int) -> String:
	@warning_ignore("integer_division")
	var total_seconds := ms / 1000
	@warning_ignore("integer_division")
	return "%d:%02d" % [total_seconds / 60, total_seconds % 60]
