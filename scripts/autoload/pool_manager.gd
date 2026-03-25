extends Node

var _pools: Dictionary = {}
var _scenes: Dictionary = {}
var _all_instances: Dictionary = {}

func register_pool(pool_name: String, scene: PackedScene, initial_count: int = 20) -> void:
	if _pools.has(pool_name):
		return
	_scenes[pool_name] = scene
	_pools[pool_name] = []
	_all_instances[pool_name] = []
	for i in initial_count:
		var instance = scene.instantiate()
		instance.set_meta("pool_name", pool_name)
		instance.process_mode = Node.PROCESS_MODE_DISABLED
		instance.visible = false
		if instance is Node2D:
			instance.position = Vector2(-9999, -9999)
		_pools[pool_name].append(instance)
		_all_instances[pool_name].append(instance)
		add_child(instance)

func acquire(pool_name: String) -> Node:
	if _pools.has(pool_name) and _pools[pool_name].size() > 0:
		var instance = _pools[pool_name].pop_back()
		instance.process_mode = Node.PROCESS_MODE_INHERIT
		instance.visible = true
		return instance
	elif _scenes.has(pool_name):
		var instance = _scenes[pool_name].instantiate()
		instance.set_meta("pool_name", pool_name)
		add_child(instance)
		if not _all_instances.has(pool_name):
			_all_instances[pool_name] = []
		_all_instances[pool_name].append(instance)
		return instance
	else:
		push_error("PoolManager: Unknown pool '%s'" % pool_name)
		return null

func release(instance: Node) -> void:
	var pool_name = instance.get_meta("pool_name", "")
	if pool_name == "":
		push_error("PoolManager: Node has no pool_name meta")
		return
	if not _pools.has(pool_name):
		_pools[pool_name] = []
	if instance in _pools[pool_name]:
		return
	instance.process_mode = Node.PROCESS_MODE_DISABLED
	instance.visible = false
	if instance is Node2D:
		instance.position = Vector2(-9999, -9999)
	_pools[pool_name].append(instance)

func clear_all_pools() -> void:
	for pool_name in _all_instances:
		for instance in _all_instances[pool_name]:
			if is_instance_valid(instance):
				instance.queue_free()
	_all_instances.clear()
	_pools.clear()
	_scenes.clear()
