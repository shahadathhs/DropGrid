class_name PieceBag
extends RefCounted
## Shuffled "7-bag": every piece appears once per bag, so long streaks can't happen.

var _rng := RandomNumberGenerator.new()
var _queue: Array[int] = []


func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()


func next_piece() -> int:
	if _queue.is_empty():
		_refill()
	return _queue.pop_back()


func _refill() -> void:
	for type in PieceData.TYPE_COUNT:
		_queue.append(type)
	# Fisher-Yates shuffle.
	for i in range(_queue.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp := _queue[i]
		_queue[i] = _queue[j]
		_queue[j] = tmp
