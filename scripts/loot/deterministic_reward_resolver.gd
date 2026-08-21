class_name DeterministicRewardResolver
extends RefCounted

## Pure seeded selection. The same definitions, seed, and roll index always
## produce the same reward.


func roll_item(items: Dictionary, run_seed: int, roll_index: int = 0) -> Dictionary:
	if items.is_empty():
		return {}
	var ordered_ids: Array = items.keys()
	ordered_ids.sort()
	var total_weight := 0.0
	for item_id in ordered_ids:
		total_weight += float((items[item_id] as Dictionary).get("drop_weight", 0.0))
	if total_weight <= 0.0:
		return {}
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed + (roll_index * 1_000_003)
	var ticket := rng.randf_range(0.0, total_weight)
	var cursor := 0.0
	for item_id in ordered_ids:
		var item: Dictionary = items[item_id]
		cursor += float(item.get("drop_weight", 0.0))
		if ticket <= cursor:
			return item.duplicate(true)
	return (items[ordered_ids.back()] as Dictionary).duplicate(true)
