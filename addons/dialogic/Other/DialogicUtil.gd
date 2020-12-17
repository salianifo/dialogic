tool
class_name DialogicUtil

static func test():
	print("Foo")


static func load_json(path):
	var file = File.new()
	if file.open(path, File.READ) != OK:
		file.close()
		return
	var data_text = file.get_as_text()
	file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return
	return data_parse.result


static func get_path(name, extra=''):
	var WORKING_DIR = "res://dialogic"
	var paths = {
		'WORKING_DIR': WORKING_DIR,
		'TIMELINE_DIR': WORKING_DIR + "/dialogs",
		'CHAR_DIR': WORKING_DIR + "/characters",
		'SETTINGS_FILE': WORKING_DIR + "/settings.json",
	}
	if extra != '':
		return paths[name] + '/' + extra
	else:
		return paths[name]


static func get_filename_from_path(path, extension = false):
	var file_name = path.split('/')[-1]
	if extension == false:
		file_name = file_name.split('.')[0]
	return file_name


static func listdir(path):
	# https://godotengine.org/qa/5175/how-to-get-all-the-files-inside-a-folder
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files


static func get_character_list():
	var characters = []
	for file in listdir(get_path('CHAR_DIR')):
		if '.json' in file:
			var data = load_json(get_path('CHAR_DIR', file))
			var color = Color("#ffffff")
			var c_name = data['id']
			var default_speaker = 'false'
			var portraits = []
			if data.has('color'):
				color = Color('#' + data['color'])
			if data.has('name'):
				c_name = data['name']
			if data.has('default_speaker'):
				default_speaker = data['default_speaker']
			if data.has('portraits'):
				portraits = data['portraits']
			characters.append({
				'name': c_name,
				'color': color,
				'file': file,
				'default_speaker' : default_speaker,
				'portraits': portraits,
			})

	return characters