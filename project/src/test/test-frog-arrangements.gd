extends GutTest

func test_positions_from_picture_triangle() -> void:
	var picture := [
		"  f  ",
		"     ",
		" f f ",
		"     ",
		"f f f",
	]
	var positions := FrogArrangements.positions_from_picture(picture)
	assert_eq(positions, [
			Vector2(-1.0, 1.0),
			Vector2(-0.5, 0.0),
			Vector2(0.0, -1.0),
			Vector2(0.0, 1.0),
			Vector2(0.5, 0.0),
			Vector2(1.0, 1.0),
	])


func test_positions_from_picture_offset() -> void:
	var picture := [
		"     ",
		"  f f",
		"     ",
		"   f ",
		"     ",
	]
	var positions := FrogArrangements.positions_from_picture(picture)
	assert_eq(positions, [
			Vector2(-0.5, -0.5),
			Vector2(0.0, 0.5),
			Vector2(0.5, -0.5),
	])


## Verifies there is at least one arrangement for every possible frog count
func test_arrangement_for_every_frog_count() -> void:
	for i in range(1, FrogArrangements.MAX_FROG_COUNT):
		assert_gt(FrogArrangements.get_arrangements(i).size(), 0)


## Verifies there are no duplicate frog arrangements
func test_no_duplicates() -> void:
	for i in range(1, FrogArrangements.MAX_FROG_COUNT):
		# key: (String) string representation of an arrangement array
		# value: (bool) true
		var arrangement_strings := {}
		for arrangement_obj in FrogArrangements.get_arrangements(i):
			var arrangement: Array = arrangement_obj
			var arrangement_string := String(arrangement)
			assert_false(arrangement_strings.has(arrangement_string),
					"Duplicate frog arrangement for size %s: %s" % [i, arrangement_string])
			arrangement_strings[arrangement_string] = true
