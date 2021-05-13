extends Control

var title_arr = []
var desc_arr = []
var link_arr = []

func _ready():
	load_data()

func _on_OpenButton_pressed():
	clearFields()
	populateEdit()

func populateEdit():
	var url = $SettingsDialog/RSSURLText.text
	$HTTPRequest.request(url)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	$TextEdit.set_text(body.get_string_from_utf8())
	
	# Initialize XML parser and set variables
	var parser = XMLParser.new()
	
	var in_item_node = false
	var in_title_node = false
	var in_description_node = false
	var in_link_node = false
	
	parser.open_buffer(body)
	
	while parser.read() == OK:
		var node_name = parser.get_node_name()
		var node_data = parser.get_node_data()
		var node_type = parser.get_node_type()
		
		if (node_name == "item"):
			in_item_node = !in_item_node
			
		if (node_name == "title") and (in_item_node == true):
			in_title_node = !in_title_node
			continue
			
		if (node_name == "description") and (in_item_node == true):
			in_description_node = !in_description_node
			continue
			
		if (node_name == "link") and (in_item_node == true):
			in_link_node = !in_link_node
			continue
			
		if(in_description_node == true):     
			if(node_data != ""):    
				desc_arr.append(node_data)   
			else:     
				desc_arr.append(node_name)
				
		if(in_title_node == true):
			if(node_data !=""):    
				title_arr.append(node_data)   
			else:   
				title_arr.append(node_name)
				
		if(in_link_node == true):   
			if(node_data != ""):    
				link_arr.append(node_data)   
			else:     
				link_arr.append(node_name)
				
	for i in title_arr:
		$ItemList.add_item(i,null,true)

func _on_ItemList_item_selected(index):
	$DescriptionField.text = desc_arr[index]
	$LinkButton.text = link_arr[index]


func _on_LinkButton_pressed():
	OS.shell_open($LinkButton.text)

func _on_SettingsButton_pressed():
	$SettingsDialog.popup()

func _on_ClearButton_pressed():
	$SettingsDialog/RSSURLText.text = ""
	
func clearFields():
	title_arr.clear()
	desc_arr.clear()
	link_arr.clear()
	$ItemList.clear()
	$DescriptionField.text = ""
	$LinkButton.text = ""
	
# Save custom RSS URL in a file:

func save_data():
	
	### Debugging
	
	print('saving data to ' + OS.get_user_data_dir() + '...')
	
	### Debugging
	
	var save_config = File.new()
	var save_data = {
		"url": $SettingsDialog/RSSURLText.text
	}
	
	save_config.open("user://save_config.save", File.WRITE)
	save_config.store_line(to_json(save_data))
	save_config.close()

func _on_SaveButton_pressed():
	save_data()
	
func load_data():
	print('loading data from ' + OS.get_user_data_dir() + '...')
	
	var save_config = File.new()
	
	if not save_config.file_exists("user://save_config.save"):
		return
		
	save_config.open("user://save_config.save", File.READ)
	
	var text = save_config.get_as_text()
	var url = parse_json(text)['url']
	
	print('Loading JSON: ' + text)
	print('URL: ' + url)
	
	$SettingsDialog/RSSURLText.text = url
	save_config.close()
