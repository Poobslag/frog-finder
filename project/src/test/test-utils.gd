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


func test_convert_dict_floats_to_ints() -> void:
	var input := {
		1562.0: "common",
		"crowded": 4632.0,
		3438.0: 1103.0,
	}
	Utils.convert_dict_floats_to_ints(input)
	
	assert_eq({
		1562: "common",
		"crowded": 4632,
		3438: 1103,
	}, input)


func test_substring_before() -> void:
	assert_eq(Utils.substring_before("b", ""), "b")
	assert_eq(Utils.substring_before("", "b"), "")
	assert_eq(Utils.substring_before("abc", "a"), "")
	assert_eq(Utils.substring_before("abcba", "b"), "a")
	assert_eq(Utils.substring_before("abc", "c"), "ab")
	assert_eq(Utils.substring_before("abc", "d"), "abc")
