@tool
extends GodotTogetherComponent
class_name GodotTogetherChangeDetector

signal scene_changed
signal node_properties_changed(node: Node, changed_keys: Array)
#signal node_property_changed(node: Node, key: String)
#signal node_property_differs(node: Node, key: String, old_value, new_value)

const IGNORED_PROPERTY_USAGE_FLAGS = [
	PROPERTY_USAGE_GROUP, 
	PROPERTY_USAGE_CATEGORY, 
	PROPERTY_USAGE_SUBGROUP
]

var observed_nodes: Array[Node]
var observed_nodes_cache = {}
var last_scene := ""

static func get_property_keys(node: Node) -> Array[String]:
	var res: Array[String] = []
	
	for i in node.get_property_list():
		var con = true
		
		for usage in IGNORED_PROPERTY_USAGE_FLAGS:
			if i.usage & usage:
				con = false
				break
			
		if not con: continue
		res.append(i.name)
		
	return res

static func get_property_dict(node: Node) -> Dictionary:
	var res = {}
	
	for i in get_property_keys(node):
		res[i] = node[i]
	
	return res

func _process(_delta):
	if not main: return
	
	var root = EditorInterface.get_edited_scene_root()
	if not root: return
	
	var current_scene_path = root.scene_file_path
	if last_scene != current_scene_path:
		last_scene = current_scene_path
		scene_changed.emit()
	
	for node in observed_nodes:
		if not node:
			continue
		if not node.is_inside_tree() or not is_instance_valid(node):
			observed_nodes.erase(node) 
			continue
		
		var cached = observed_nodes_cache[node]
		var current = get_property_dict(node)
		
		var changed_keys = []
		
		for i in current.keys():
			if cached[i] != current[i]:
				#node_property_changed.emit(node, i)
				#node_property_differs.emit(node, i, cached[i], current[i])
				changed_keys.append(i)
				
		if changed_keys.size() != 0:
			node_properties_changed.emit(node, changed_keys)
			observed_nodes_cache[node] = current
	

func observe(node: Node):
	if node in observed_nodes: return
	observed_nodes_cache[node] = get_property_dict(node)
	observed_nodes.append(node)
	
	# property_list_changed doesn't fire in editor
	#var cache = get_property_dict(node)
	#
	#var on_change = func():
		#var changed_keys = []
		#var current = get_property_dict(node)
		#
		#for i in current.keys():
			#if cache[i] != current[i]:
				#node_property_changed.emit(node, i)
				#node_property_differs.emit(node, i, cache[i], current[i])
				#changed_keys.append(i)
		#
		#node_properties_changed.emit(node, changed_keys)
		#cache = current
	#
	#node.property_list_changed.connect(on_change)
	#node.tree_exiting.connect(func():
		#node.property_list_changed.disconnect(on_change)
	#)

func observe_recursive(node: Node):
	observe(node)
	
	for i in GodotTogetherUtils.get_descendants(node):
		observe(i)
