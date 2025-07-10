# scripts/tests/BiomeTestMain.gd
extends Node

# Fixed BiomeTestMain - removed all try/except blocks

var biome_math_core: BiomeMathCore
var test_results: Dictionary = {}
var test_output: TextEdit
var performance_label: Label
var test_start_time: float = 0.0

func _ready():
	_setup_ui_references()
	_initialize_biome_math_core()
	_run_initial_tests()
	_log("✅ BiomeTestMain ready! Press T to run all tests")

func _setup_ui_references():
	test_output = get_node_or_null("UI/TestOutput")
	performance_label = get_node_or_null("UI/PerformanceLabel")
	
	if not test_output:
		print("ERROR: TestOutput not found")
		return
	
	if not performance_label:
		print("ERROR: PerformanceLabel not found")
		return
	
	test_output.text = "BiomeMathCore Architecture Test\nInitializing...\n"
	performance_label.text = "Performance: Initializing..."

func _initialize_biome_math_core():
	_log("🔧 Initializing BiomeMathCore...")
	
	# Create BiomeMathCore instance
	biome_math_core = BiomeMathCore.new()
	
	if not biome_math_core:
		_log("❌ ERROR: Failed to initialize BiomeMathCore")
		return
	
	# Setup test biome composition
	var test_composition = {
		"imperium": 0.4,
		"biotic_flux": 0.3,
		"entropy_garden": 0.2,
		"masquerade_court": 0.1
	}
	
	biome_math_core.setup_for_biome(test_composition)
	
	# Connect signals if they exist
	if biome_math_core.has_signal("state_evolved"):
		biome_math_core.state_evolved.connect(_on_state_evolved)
	
	_log("✅ BiomeMathCore initialized successfully")

func _on_state_evolved(new_state: Array):
	if performance_label:
		var energy = 0.0
		for component in new_state:
			if component is Vector2:
				energy += component.length()
		performance_label.text = "Performance: Energy=%.2f, Components=%d" % [energy, new_state.size()]

func _log(message: String):
	print(message)
	if test_output:
		test_output.text += message + "\n"
		test_output.scroll_vertical = test_output.get_line_count()

func _run_initial_tests():
	_log("🧪 Running initial tests...")
	
	if not biome_math_core:
		_log("❌ Cannot run tests - BiomeMathCore not initialized")
		return
	
	_test_basic_functionality()
	_log("✅ Initial tests completed")

func _test_basic_functionality():
	_log("Testing basic functionality...")
	
	# Test system state
	var system_state = biome_math_core.get_system_state()
	if system_state and system_state.has("total_energy"):
		test_results["system_state"] = "PASS"
		_log("✅ System state accessible")
	else:
		test_results["system_state"] = "FAIL - No energy data"
		_log("❌ System state missing energy data")
	
	# Test node graph
	var node_graph = biome_math_core.get_node_graph()
	if node_graph and node_graph.has_method("get_node_count") and node_graph.get_node_count() > 0:
		test_results["node_graph"] = "PASS - %d nodes" % node_graph.get_node_count()
		_log("✅ Node graph working: %d nodes" % node_graph.get_node_count())
	else:
		test_results["node_graph"] = "FAIL - No nodes"
		_log("❌ Node graph failed")
	
	# Test biome composition
	var composition = biome_math_core.get_biome_composition()
	if composition and composition.has_method("get_composition_data"):
		var comp_data = composition.get_composition_data()
		if comp_data and comp_data.has("dominant_icons"):
			test_results["biome_composition"] = "PASS"
			_log("✅ Biome composition working")
		else:
			test_results["biome_composition"] = "FAIL - No dominant icons"
			_log("❌ Biome composition missing data")
	else:
		test_results["biome_composition"] = "FAIL - No composition"
		_log("❌ Biome composition failed")
	
	# Test sprite state
	var sprite_state = biome_math_core.get_sprite_state()
	if sprite_state and sprite_state.has("total_sprite_count"):
		test_results["sprite_state"] = "PASS"
		_log("✅ Sprite state working")
	else:
		test_results["sprite_state"] = "FAIL - No sprite count"
		_log("❌ Sprite state failed")

func _process(delta):
	if biome_math_core and biome_math_core.has_method("evolve"):
		biome_math_core.evolve(delta)
		
		# Update resource budgets - FIXED: Check if property exists by checking if it's not null
		if biome_math_core.influence_budget and biome_math_core.influence_budget.has_method("regenerate"):
			biome_math_core.influence_budget.regenerate(delta)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_deploy_random_tool()
			KEY_2:
				_paint_random_influence()
			KEY_3:
				_compress_random_node()
			KEY_R:
				_reset_system()
			KEY_P:
				_run_performance_test()
			KEY_T:
				_run_all_tests()

func _deploy_random_tool():
	_log("🔧 Deploying random tool...")
	
	if not biome_math_core:
		_log("❌ No BiomeMathCore available")
		return
	
	var tools = ["spark", "druid", "operator", "icon_paintbrush"]
	var tool_name = tools[randi() % tools.size()]
	var node_index = randi() % 7
	
	if biome_math_core.has_method("can_deploy_tool") and biome_math_core.can_deploy_tool(tool_name, node_index):
		var result = biome_math_core.deploy_tool(tool_name, node_index)
		if result and result.get("success", false):
			_log("✅ Deployed %s at node %d" % [tool_name, node_index])
		else:
			_log("❌ Failed to deploy %s: %s" % [tool_name, result.get("error", "Unknown error")])
	else:
		_log("❌ Cannot deploy %s at node %d" % [tool_name, node_index])

func _paint_random_influence():
	_log("🎨 Painting random influence...")
	
	if not biome_math_core:
		_log("❌ No BiomeMathCore available")
		return
	
	var icons = ["imperium", "biotic_flux", "entropy_garden", "masquerade_court"]
	var icon_name = icons[randi() % icons.size()]
	var node_index = randi() % 7
	var strength = randf_range(0.1, 0.5)
	
	if biome_math_core.has_method("can_paint_influence") and biome_math_core.can_paint_influence(node_index, strength):
		var influence_data = {"icon_name": icon_name, "strength": strength}
		var result = biome_math_core.paint_influence(node_index, influence_data)
		if result and result.get("success", false):
			_log("✅ Painted %s influence at node %d" % [icon_name, node_index])
		else:
			_log("❌ Failed to paint influence: %s" % result.get("error", "Unknown error"))
	else:
		_log("❌ Cannot paint influence at node %d" % node_index)

func _compress_random_node():
	_log("🗜️ Compressing random node...")
	
	if not biome_math_core:
		_log("❌ No BiomeMathCore available")
		return
	
	var node_index = randi() % 7
	if biome_math_core.has_method("compress_node"):
		var result = biome_math_core.compress_node(node_index)
		if result and result.get("success", false):
			_log("✅ Compressed node %d" % node_index)
		else:
			_log("❌ Failed to compress node %d: %s" % [node_index, result.get("error", "Unknown error")])
	else:
		_log("❌ compress_node method not available")

func _reset_system():
	_log("🔄 Resetting system...")
	_initialize_biome_math_core()

func _run_performance_test():
	_log("⚡ Running performance test...")
	
	if not biome_math_core:
		_log("❌ No BiomeMathCore available")
		return
	
	var start_time = Time.get_time_dict_from_system()
	
	# Run evolution for many steps
	for i in range(1000):
		if biome_math_core.has_method("evolve"):
			biome_math_core.evolve(0.016)
	
	var end_time = Time.get_time_dict_from_system()
	_log("✅ Performance test completed")

func _run_all_tests():
	_log("\n🧪 Running comprehensive test suite...")
	test_results.clear()
	
	_test_dynamical_system()
	_test_node_graph()
	_test_biome_composition()
	_test_sprite_system()
	_test_tool_system()
	_test_influence_system()
	_test_operator_system()
	
	_print_test_results()

func _test_dynamical_system():
	_log("Testing DynamicalSystem...")
	
	if not biome_math_core or not biome_math_core.quantum_system:
		test_results["quantum_state"] = "FAIL - No quantum system"
		_log("ERROR: DynamicalSystem not available")
		return
	
	var quantum_system = biome_math_core.quantum_system
	if not quantum_system:
		test_results["quantum_state"] = "FAIL - Quantum system is null"
		return
	
	# Test state vector
	if quantum_system.has_method("get_state_snapshot"):
		var state = quantum_system.get_state_snapshot()
		if state and state.size() > 0:
			test_results["quantum_state"] = "PASS - %d components" % state.size()
		else:
			test_results["quantum_state"] = "FAIL - No state vector"
	else:
		test_results["quantum_state"] = "FAIL - No get_state_snapshot method"
	
	# Test system energy
	if quantum_system.has_method("get_system_energy"):
		var energy = quantum_system.get_system_energy()
		if energy > 0:
			test_results["system_energy"] = "PASS - %.2f energy" % energy
		else:
			test_results["system_energy"] = "FAIL - No energy"
	else:
		test_results["system_energy"] = "FAIL - No get_system_energy method"
	
	_log("DynamicalSystem tests completed")

func _test_node_graph():
	_log("Testing NodeGraph...")
	
	if not biome_math_core or not biome_math_core.has_method("get_node_graph"):
		test_results["node_count"] = "FAIL - No get_node_graph method"
		return
	
	var node_graph = biome_math_core.get_node_graph()
	if not node_graph:
		test_results["node_count"] = "FAIL - Node graph is null"
		return
	
	# Test node count
	if node_graph.has_method("get_node_count"):
		var node_count = node_graph.get_node_count()
		if node_count > 0:
			test_results["node_count"] = "PASS - %d nodes" % node_count
		else:
			test_results["node_count"] = "FAIL - No nodes"
	else:
		test_results["node_count"] = "FAIL - No get_node_count method"
	
	_log("NodeGraph tests completed")

func _test_biome_composition():
	_log("Testing BiomeComposition...")
	
	if not biome_math_core or not biome_math_core.has_method("get_biome_composition"):
		test_results["composition_data"] = "FAIL - No get_biome_composition method"
		return
	
	var composition = biome_math_core.get_biome_composition()
	if not composition:
		test_results["composition_data"] = "FAIL - Composition is null"
		return
	
	# Test composition data
	if composition.has_method("get_composition_data"):
		var comp_data = composition.get_composition_data()
		if comp_data and comp_data.has("dominant_icons"):
			test_results["composition_data"] = "PASS - %d dominant icons" % comp_data["dominant_icons"].size()
		else:
			test_results["composition_data"] = "FAIL - No dominant icons"
	else:
		test_results["composition_data"] = "FAIL - No get_composition_data method"
	
	_log("BiomeComposition tests completed")

func _test_sprite_system():
	_log("Testing SpriteState...")
	
	if not biome_math_core or not biome_math_core.has_method("get_sprite_state"):
		test_results["sprite_state"] = "FAIL - No get_sprite_state method"
		return
	
	var sprite_state = biome_math_core.get_sprite_state()
	if not sprite_state:
		test_results["sprite_state"] = "FAIL - Sprite state is null"
		return
	
	# Test sprite state data
	if sprite_state.has("total_sprite_count"):
		test_results["sprite_state"] = "PASS - %d sprites" % sprite_state["total_sprite_count"]
	else:
		test_results["sprite_state"] = "FAIL - No sprite count"
	
	_log("SpriteState tests completed")

func _test_tool_system():
	_log("Testing ToolSystem...")
	
	if not biome_math_core or not biome_math_core.has_method("can_deploy_tool"):
		test_results["tool_deployment_check"] = "FAIL - No tool system methods"
		return
	
	# Test tool deployment check
	var can_deploy = biome_math_core.can_deploy_tool("spark", 0)
	test_results["tool_deployment_check"] = "PASS" if can_deploy else "FAIL - Cannot deploy spark"
	
	_log("ToolSystem tests completed")

func _test_influence_system():
	_log("Testing InfluenceSystem...")
	
	if not biome_math_core or not biome_math_core.has_method("can_paint_influence"):
		test_results["influence_check"] = "FAIL - No influence system methods"
		return
	
	# Test influence painting check
	var can_paint = biome_math_core.can_paint_influence(0, 0.3)
	test_results["influence_check"] = "PASS" if can_paint else "FAIL - Cannot paint influence"
	
	_log("InfluenceSystem tests completed")

func _test_operator_system():
	_log("Testing OperatorSystem...")
	
	if not biome_math_core or not biome_math_core.operator_system:
		test_results["operator_definitions"] = "FAIL - No operator system"
		return
	
	var operator_system = biome_math_core.operator_system
	if not operator_system:
		test_results["operator_definitions"] = "FAIL - Operator system is null"
		return
	
	# Test operator definitions
	if operator_system.has_method("get_available_operators"):
		var available_operators = operator_system.get_available_operators()
		if available_operators and available_operators.size() > 0:
			test_results["operator_definitions"] = "PASS - %d operators" % available_operators.size()
		else:
			test_results["operator_definitions"] = "FAIL - No operators"
	else:
		test_results["operator_definitions"] = "FAIL - No get_available_operators method"
	
	_log("OperatorSystem tests completed")

func _print_test_results():
	_log("\n📊 TEST RESULTS SUMMARY")
	_log("==================================================")  # Fixed: GDScript doesn't support "=" * 50
	
	var total_tests = test_results.size()
	var passed_tests = 0
	
	for test_name in test_results:
		var result = test_results[test_name]
		var status = "✅" if result.begins_with("PASS") else "❌"
		_log("%s %s: %s" % [status, test_name, result])
		
		if result.begins_with("PASS"):
			passed_tests += 1
	
	_log("==================================================")  # Fixed: GDScript doesn't support "=" * 50
	_log("📈 OVERALL: %d/%d tests passed (%.1f%%)" % [passed_tests, total_tests, (passed_tests * 100.0) / total_tests])
	
	if passed_tests == total_tests:
		_log("🎉 ALL TESTS PASSED! System is working correctly! 🎉")
	else:
		_log("⚠️  Some tests failed. Check output above.")
