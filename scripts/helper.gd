class_name Helper

# black, red, green, yellow, blue, magenta, pink, purple, cyan, white, orange, gray
enum colors{BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, PINK, PURPLE, CYAN, WHITE, ORANGE, GRAY}
static var colors_dictionary: Dictionary = {
	colors.BLACK: "black",
	colors.RED: "red",
	colors.GREEN: "green",
	colors.YELLOW: "yellow",
	colors.BLUE: "blue",
	colors.MAGENTA: "magenta",
	colors.PINK: "pink",
	colors.PURPLE: "purple",
	colors.CYAN: "cyan",
	colors.WHITE: "white",
	colors.ORANGE: "orange",
	colors.GRAY: "gray",
}

static var templates: Dictionary = {
	"player": 		CustomMessageTemplate.new(colors_dictionary[colors.CYAN],false,"PLAYER",true),
	"player_bold": 	CustomMessageTemplate.new(colors_dictionary[colors.CYAN],true,"PLAYER",true),
	"enemy":		CustomMessageTemplate.new(colors_dictionary[colors.WHITE],false,"ENEMY",true),
	"game_manager": CustomMessageTemplate.new(colors_dictionary[colors.YELLOW],true,"GameManager",true),
}
#static var template_player: CustomMessageTemplate = CustomMessageTemplate.new("blue",true,"",true)

static func print_error(message: String) -> void:
	#print_rich("[color=red][b]ERROR: " + string + "[/b][/color]") # Prints out "Hello world!" in green with a bold font
	push_error(message)

static func print_success(message: String) -> void:
	print_rich("[color=green][b]SUCCESS: " + message + "[/b][/color]") # Prints out "Hello world!" in green with a bold font
	
static func print_warning(message: String) -> void:
	print_rich("[color=yellow][b]WARNING: " + message + "[/b][/color]") # Prints out "Hello world!" in green with a bold font

static func print_template(template_name: String, message: String, tag: String = "") -> void:
	var template: CustomMessageTemplate = templates[template_name]
	var bold_starter: String = "[b]"
	var bold_ender: String = "[/b]"
	var color_starter: String = "[color=" + template.color + "]"
	var color_ender: String = "[/color]"
	var formatted_title: String = ""
	var formatted_tag: String = ""
	if template.title != "":
		formatted_title = color_starter + "[b]" + template.title + ": [/b]" + color_ender
	if not template.bold:
		bold_starter = ""
		bold_ender = ""
	if template.only_title_is_colored:
		color_starter = ""
		color_ender = ""
	if tag != "":
		formatted_tag = "[" + tag + "] "
	print_rich(str(Time.get_ticks_msec()/1000.0) + " " + formatted_title + formatted_tag + color_starter + bold_starter + message + bold_ender + color_ender) # Prints out "Hello world!" in green w

static func print_custom(color: int, bold: bool, title_only: bool, message: String) -> void:
	var bold_string: String = ""
	var bold_ending_string: String = ""
	var color_string: String = colors_dictionary[color]
	if bold:
		bold_string = "[b]"
		bold_ending_string = "[/b]"
		print_rich("[color=" + color_string + "]" + bold_string + message + bold_ending_string + "[/color]") # Prints out "Hello world!" in green with a bold font
	else:
		print_rich("[color=" + color_string + "]" + message + "[/color]") # Prints out "Hello world!" in green with a bold font

static func dir_contents_filter(path: String, extension: String, print: bool = false) -> Array[String]:
	var dir: = DirAccess.open(path)
	var fixed_path: String
	var file_list: Array[String] = []
	if dir:
		dir.list_dir_begin()
		fixed_path = dir.get_current_dir()
		#print_debug("fixed path is " + fixed_path)
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(extension):
					#print_debug("Found a " + extension + " file: " + file_name)
					var file_name_path: String = fixed_path + "/" + file_name
					file_list.append(file_name_path)
					if print:
						print_debug("added to file list: " + file_name_path)
					
				#print_debug("Found directory: " + file_name)
			#else:
				#print_debug("Found file: " + file_name)
				
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print_debug("An error occurred when trying to access the path: " + path)
	return file_list


class CustomMessageTemplate:
	var color: String = "yellow"
	var bold: bool = true
	var title: String = ""
	var only_title_is_colored: bool = false	
	
	func _init(color: String, bold: bool, title: String = "", only_title_is_colored: bool = false) -> void:
		self.color = color
		self.bold = bold
		self.title = title
		self.only_title_is_colored = only_title_is_colored
