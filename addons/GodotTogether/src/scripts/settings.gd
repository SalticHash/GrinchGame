extends Node
class_name GodotTogetherSettings

const default_data = {
	"username": "Cool person",
	"format_version": 1,
	
	"last_server": "",
	"last_port": 5017,
	
	"server": {
		"password": "", # hashed password string
		"whitelist": ["127.0.0.1", "0.0.0.0", "0:0:0:0:0:0:0:1"], # IP address whitelist
		"blacklist": [], # blocked IP addresses
		"whitelist_enabled": false,
		"allow_external_connections": true # allow connections outside of the local network (if the user has open ports) 
	}
}

const file_path = "res://addons/GodotTogether/settings.json"

static func make_editable(dict: Dictionary) -> Dictionary:
	if not dict.is_read_only(): return dict
	
	var res = {}
	for key in dict.keys():
		res[key] = dict[key]
	
	return res

static func write_settings(data: Dictionary):
	var f = FileAccess.open(file_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data," "))
	f.close()

static func settings_exist() -> bool:
	return FileAccess.file_exists(file_path)

static func create_settings():
	write_settings(default_data)

static func get_settings() -> Dictionary:
	if settings_exist():
		var f = FileAccess.open(file_path, FileAccess.READ)
		var parsed = JSON.parse_string(f.get_as_text())
		
		if not parsed:
			push_error("Parsing settings failed, returning default data")
			return make_editable(default_data)
		
		for key in default_data.keys():
			if not parsed.has(key):
				parsed[key] = default_data[key]
		
		return make_editable(parsed)
		
	else:
		return make_editable(default_data)

static func get_nested(dict: Dictionary, path:String, separator := "/"):
	var levels = path.split(separator)
	var current = dict
	
	for level in levels:
		if not current.has(level): return
		current = current[level]
	
	return current

static func set_nested(dict: Dictionary, path: String, value, separator:= "/"):
	assert(not dict.is_read_only(), "Dictionary is read only")
	
	var levels = path.split(separator)
	var current = dict

	for i in range(levels.size() - 1):
		var level = levels[i]
		if not current.has(level):
			current[level] = {}
		
		current = current[level]

	current[levels[-1]] = value

static func get_setting(path: String):
	return get_nested(get_settings(), path)

static func set_setting(path: String, value):
	var data = get_settings()
	set_nested(data, path, value)
	write_settings(data)
