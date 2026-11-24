extends GdUnitTestSuite
## LevelHost (F8 task 3): loads a level from the catalog in the background, swaps it in,
## hosts it through its LevelEntry, restarts it and unloads it; unknown ids and a second
## load while one runs are refused.

const FIXTURE: String = "res://scenes/tests/level_host_fixture.tscn"

var _host: LevelHost
var _loading: LoadingScreen


func before_test() -> void:
	var catalog := LevelCatalog.new()
	catalog.levels = {&"fixture": FIXTURE}
	catalog.first_level = &"fixture"
	_loading = auto_free(LoadingScreen.new())
	add_child(_loading)
	_host = auto_free(LevelHost.new())
	_host.catalog = catalog
	_host.loading = _loading
	add_child(_host)


func _wait_loaded() -> void:
	for i: int in 300:
		if not _host.is_loading():
			return
		await get_tree().process_frame


func test_loads_and_hosts_a_level() -> void:
	assert_bool(_host.load_level(&"fixture")).is_true()
	assert_bool(_loading.is_showing()).is_true()
	await _wait_loaded()
	assert_str(String(_host.current_id())).is_equal("fixture")
	var level: Node = _host.current_level()
	assert_object(level).is_not_null()
	assert_object(level.get_parent()).is_same(_host)
	assert_bool((level.get_node(^"LevelEntry") as LevelEntry).is_hosted()).is_true()
	assert_bool(_loading.is_showing()).is_false()
	assert_float(_host.last_load_seconds).is_greater_equal(0.0)


func test_refuses_unknown_ids_and_double_loads() -> void:
	assert_bool(_host.load_level(&"nowhere")).is_false()
	assert_bool(_host.load_level(&"fixture")).is_true()
	assert_bool(_host.load_level(&"fixture")).is_false()
	await _wait_loaded()


func test_restart_swaps_in_a_fresh_copy() -> void:
	_host.load_level(&"fixture")
	await _wait_loaded()
	var first: Node = _host.current_level()
	assert_bool(_host.restart()).is_true()
	await _wait_loaded()
	assert_object(_host.current_level()).is_not_same(first)
	assert_int(_host.get_child_count()).is_equal(1)


func test_unload_leaves_nothing() -> void:
	_host.load_level(&"fixture")
	await _wait_loaded()
	_host.unload()
	assert_object(_host.current_level()).is_null()
	assert_str(String(_host.current_id())).is_empty()
	assert_bool(_host.restart()).is_false()


func test_the_level_can_ask_for_the_title() -> void:
	_host.load_level(&"fixture")
	await _wait_loaded()
	var asked: Array[bool] = [false]
	_host.title_requested.connect(func() -> void: asked[0] = true)
	(_host.current_level().get_node(^"LevelEntry") as LevelEntry).title_requested.emit()
	await get_tree().process_frame
	assert_bool(asked[0]).is_true()
