extends Object
class_name Util

enum PhysicsLayer {
	WALL = 1 << 0,
	GROUND = 1 << 1,
	PLAYER = 1 << 2,
}


static func is_compatibility_renderer() -> bool:
	var rendering_method: String = (
		ProjectSettings["rendering/renderer/rendering_method"]
	)
	return rendering_method == "gl_compatibility"


static func get_inertia(body: RigidBody3D) -> Vector3:
	var state := PhysicsServer3D.body_get_direct_state(body.get_rid())
	return state.inverse_inertia.inverse()


static func is_web_browser() -> bool:
	return OS.get_name() == "Web"


static func get_default_gravity() -> float:
	return ProjectSettings.get_setting("physics/3d/default_gravity")


static func get_files_recursive(path: String) -> Array[String]:
	return _get_files_recursive(path, [])


static func _get_files_recursive(
	path: String, files: Array[String] = []
) -> Array[String]:
	var dir := DirAccess.open(path)
	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			var file_path := dir.get_current_dir().path_join(file_name)
			if dir.current_is_dir():
				files = _get_files_recursive(file_path, files)
			else:
				files.append(file_path)
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access %s" % path)
	return files


# Like Node3D.look_at but won't error
static func safe_look_at(
	node: Node3D, target: Vector3, use_model_front: bool = false
) -> void:
	var p : Vector3 = node.global_transform.origin
	if p.is_equal_approx(target):
		return
	var v := p.direction_to(target)
	var ws := [Vector3.UP, Vector3.FORWARD, Vector3.LEFT]
	for w: Vector3 in ws:
		var is_parallel := is_equal_approx(absf(v.dot(w)), 1.0)
		if not w.cross(target - p).is_zero_approx() and not is_parallel:
			node.look_at(target, w, use_model_front)


# Point is global
static func get_point_velocity(body: RigidBody3D, point: Vector3) -> Vector3:
	return (
		body.linear_velocity
		+ body.angular_velocity.cross(point - body.global_transform.origin)
	)


static func get_ticks_sec() -> float:
	return Time.get_ticks_msec() / 1000.0


static func get_vector3_xz(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)


static func vector_3_to_dictionary(v: Vector3) -> Dictionary:
	return { "x": v.x, "y": v.y, "z": v.z }


static func dictionary_to_vector_3(d: Dictionary) -> Vector3:
	return Vector3(d["x"], d["y"], d["z"])


static func is_graph_connected(pairs: Array) -> bool:
	if pairs.size() == 0:
		return true

	var graph = {}
	for pair in pairs:
		var a = pair[0]
		var b = pair[1]
		if not graph.has(a):
			graph[a] = []
		if not graph.has(b):
			graph[b] = []
		graph[a].append(b)
		graph[b].append(a)

	var visited = {}
	var nodes = graph.keys()
	var stack = [nodes[0]]
	visited[nodes[0]] = true

	while stack.size() > 0:
		var node = stack.pop_back()
		for neighbor in graph[node]:
			if not visited.has(neighbor):
				visited[neighbor] = true
				stack.append(neighbor)

	return visited.size() == nodes.size()


static func direction_to_quaternion(direction: Vector3) -> Quaternion:
	var forward = Vector3(0.0, 0.0, 1.0)
	var dot = forward.dot(direction)
	var cross = forward.cross(direction).normalized()
	var angle = acos(dot)
	if is_zero_approx(angle):
		return Quaternion.IDENTITY
	return Quaternion(cross, angle)


static func get_children_recursive(
	node: Node, include_internal := false
) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in node.get_children(include_internal):
		nodes.append(child)
		if child.get_child_count(include_internal) > 0:
			nodes.append_array(get_children_recursive(child, include_internal))
	return nodes
