class_name ScoreServerHttpRequest
extends Node

signal request_completed(json_dict)

func _ready() -> void:
	$HTTPRequest.connect("request_completed", Callable(self, "_on_request_completed"))	

func _log(text) -> void:
	print(str(text))

func _show_error(text) -> String:
	printerr("ERROR: "+ str(text))
	return text

func make_request(url: String, json_str: String) -> void:
	_log("request: " + url + ", json: " + json_str)
	
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	
	$HTTPRequest.request(url, headers, false, HTTPClient.METHOD_POST, json_str)	

func _on_request_completed(result, response_code, headers, body):
	_log("response: " + str(response_code)) #+ ", json: " + body.get_string_from_utf8())
	
	var res_str: String
	
	if response_code == 200:
		var test_json_conv = JSON.new()
		test_json_conv.parse(body.get_string_from_utf8())
		var parsed_json: JSON = test_json_conv.get_data()
		
		if parsed_json.error == OK:
			# check for parse format and error
			if typeof(parsed_json.result) == TYPE_DICTIONARY:
				res_str = parsed_json.result['status']		
				emit_signal("request_completed", parsed_json.result)
				return
			else:
				res_str = _show_error("JSON response should be a dictionary or an array")
		else:
			res_str = _show_error("JSON parse error")
	else:
		res_str = _show_error("The requested URL could not be retrieved")
		
	_log("result: " + res_str)
	
	emit_signal("request_completed", null)
