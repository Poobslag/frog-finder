extends GutTest

func test_get_world_titles() -> void:
	assert_eq("fr?g f?nder", WorldData.get_world(0).title)
	assert_eq("s?nshine shoa?s", WorldData.get_world(1).title)
