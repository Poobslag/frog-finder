extends GutTest

func test_erase_single_character() -> void:
	assert_eq(Utils.erase("solid", 0, 1), "olid")
	assert_eq(Utils.erase("solid", 2, 1), "soid")
	assert_eq(Utils.erase("solid", 4, 1), "soli")
	assert_eq(Utils.erase("solid", -1, 1), "solid")
	assert_eq(Utils.erase("solid", 10, 1), "solid")


func test_erase_multiple_characters() -> void:
	assert_eq(Utils.erase("solid", 2, 2), "sod")
	assert_eq(Utils.erase("solid", 4, 3), "soli")
	assert_eq(Utils.erase("solid", -1, 3), "lid")
	assert_eq(Utils.erase("solid", -1, 10), "")
