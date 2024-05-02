extends GutTest

func test_positions_from_picture_triangle() -> void:
	var picture: Array[String] = [
		"  1  ",
		"     ",
		" 2 6 ",
		"     ",
		"3 4 5",
	]
	var positions := CardArrangements.positions_from_picture(picture)
	assert_eq(positions, [
			Vector2(1.0, 0.0),
			Vector2(0.5, 1.0),
			Vector2(0.0, 2.0),
			Vector2(1.0, 2.0),
			Vector2(2.0, 2.0),
			Vector2(1.5, 1.0),
	])


func test_positions_from_picture_offset() -> void:
	var picture: Array[String] = [
		"     ",
		"   1 ",
		"     ",
		"  2 3",
		"     ",
	]
	var positions := CardArrangements.positions_from_picture(picture)
	assert_eq(positions, [
			Vector2(0.5, 0.0),
			Vector2(0.0, 1.0),
			Vector2(1.0, 1.0),
	])
