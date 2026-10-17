extends GutTest
## Autoloads are looked up by name at run time, so a call to a member an autoload does
## not define only fails when it runs ("Nonexistent function"), and then only for the
## players who reach that code. This scans the game's scripts and checks that every
## Save., Sync., Sfx., and Music. member they use really exists.

const SCAN_DIRS := ["res://scripts", "res://autoload"]


func _source_files() -> Array[String]:
	var files: Array[String] = []
	for dir_path in SCAN_DIRS:
		for file_name in DirAccess.get_files_at(dir_path):
			if file_name.ends_with(".gd"):
				files.append(dir_path + "/" + file_name)
	return files


func _has_member(node: Node, member: String) -> bool:
	if node.has_method(member) or node.has_signal(member):
		return true
	for property in node.get_property_list():
		if property.name == member:
			return true
	return node.get_script().get_script_constant_map().has(member)


func test_every_autoload_member_used_in_the_code_exists() -> void:
	var regex := RegEx.create_from_string("(?<![\\w.])(Save|Sync|Sfx|Music)\\.([A-Za-z_]\\w*)")
	var missing: Array[String] = []
	for path in _source_files():
		var lines := FileAccess.get_file_as_string(path).split("\n")
		for index in lines.size():
			# Ignore comments: they may mention a file such as "save.gd" by name.
			var code := lines[index].split("#")[0]
			for found in regex.search_all(code):
				var singleton := found.get_string(1)
				var member := found.get_string(2)
				var where := "%s:%d" % [path, index + 1]
				var autoload := get_tree().root.get_node_or_null(singleton)
				if autoload == null:
					missing.append("%s autoload %s is not loaded" % [where, singleton])
				elif not _has_member(autoload, member):
					missing.append("%s %s.%s does not exist" % [where, singleton, member])
	assert_eq(missing, [], "calls to autoload members that do not exist")
