extends Control

var wordData = "res://wardle.json"
var keybutton = preload("res://key.tscn")
var dayWords := []
var acceptedWords := []
var currentDay : int
var keyboardDic = {}

var currentword : String
var currentGuess : String
var guessList = []
var attempts = 0

var streak : int
var prevDay : int

func _ready():
#	$title.text = 
	var json = load_json()
	dayWords = json['wordList']
	acceptedWords = json['stringList']
	#each day adds 86400 to the unix time, currently 1688515200 on 7/5/23
	currentDay = snapped(Time.get_unix_time_from_system(), 86400)
	if currentDay > Time.get_unix_time_from_system():
		currentDay -= 86400
	currentword = dayWords[(currentDay - 1688601600)/86400]
	currentword = currentword.to_upper()
	
	currentword = 'SEETH'
	
	var toprow = ['Q','W','E','R','T','Y','U','I','O','P']
	for i in len(toprow):
		var key  = keybutton.instantiate()
		$keyboard.add_child(key)
		key.text = toprow[i]
		key.position.y -= 266 #60
		key.position.x -= 334
		key.position.x += 72*i
		key.connect('pressed', keyconnect.bind(toprow[i]))
		key["theme_override_styles/normal"] = key["theme_override_styles/normal"].duplicate()
		key["theme_override_styles/normal"].bg_color = Color("#323634")
		keyboardDic[toprow[i]] = key.get_instance_id()
	var middlerow = ['A','S','D','F','G','H','J','K','L']
	for i in len(middlerow):
		var key  = keybutton.instantiate()
		$keyboard.add_child(key)
		key.text = middlerow[i]
		key.position.y -= 163
		key.position.x -= 288
		key.position.x += 72*i
		key.connect('pressed', keyconnect.bind(middlerow[i]))
		key["theme_override_styles/normal"] = key["theme_override_styles/normal"].duplicate()
		key["theme_override_styles/normal"].bg_color = Color("#323634")
		keyboardDic[middlerow[i]] = key.get_instance_id()
	var bottomrow = ['↩','Z','X','C','V','B','N','M', '⌫']
	for i in len(bottomrow):
		var key  = keybutton.instantiate()
		$keyboard.add_child(key)
		key.text = bottomrow[i]
		key.position.y -= 60
		key.position.x -= 334
		key.position.x += 72*i
		
		if bottomrow[i] == '↩':
			key.size.x += 45
		if bottomrow[i] == '⌫':
			key.size.x += 10
		if not bottomrow[i] == '↩':
			key.position.x += 45
		key.connect('pressed', keyconnect.bind(bottomrow[i]))
		key["theme_override_styles/normal"] = key["theme_override_styles/normal"].duplicate()
		key["theme_override_styles/normal"].bg_color = Color("#323634")
		keyboardDic[bottomrow[i]] = key.get_instance_id()
	
	print(keyboardDic)
	
	for i in $guessContainer.get_children():
		i["theme_override_styles/panel"] = i["theme_override_styles/panel"].duplicate()
	
#	$guessContainer/Panel["theme_override_styles/panel"].bg_color = Color("#323634")
	# orange: b59f3b
	#green: 538d4e
	
func keyconnect(key):
	print('currentGuessFEED ME: ', key)
	if key == '⌫' and not currentGuess == '':
		
		$guessContainer.get_node('guessPanel' + str(len(currentGuess)+(attempts*5))).get_child(0).text = ' '
		
		$guesses.text = $guesses.text.left(-3)
		currentGuess = currentGuess.left(-1)
		
	elif key == '↩' and len(currentGuess) == 5:
		print(currentGuess.to_lower())
		if  acceptedWords.has(currentGuess.to_lower()) or dayWords.has(currentGuess.to_lower()):
			print('it liked it!')
			guessCheck()
			$guesses.text += '\n'
			currentGuess = ''
		else:
			acceptedWords.reverse()
			print(acceptedWords)
			pass #lil msg about not a word or not long enough
	elif key == '⌫' or key == '↩':
		pass
	elif len(currentGuess) < 5:
		$guesses.text += key + '  '
		currentGuess += key
		
		$guessContainer.get_node('guessPanel' + str(len(currentGuess)+(attempts*5))).get_child(0).text = key
	print(currentGuess)

func guessCheck():
	
	for i in 5:
		instance_from_id(keyboardDic[currentGuess[i]])["theme_override_styles/normal"].bg_color = Color("#141414")
		for j in currentword:				#yellow check
			printt(currentGuess[i],j)
			if currentGuess[i] == j:
				$guessContainer.get_child(attempts*5 + i)["theme_override_styles/panel"].bg_color = Color("#b59f3b")
				instance_from_id(keyboardDic[currentGuess[i]])["theme_override_styles/normal"].bg_color = Color("#b59f3b")
		if currentword[i] == currentGuess[i]:#green check
			$guessContainer.get_child(attempts*5 + i)["theme_override_styles/panel"].bg_color = Color("#538d4e")
			instance_from_id(keyboardDic[currentGuess[i]])["theme_override_styles/normal"].bg_color = Color("#538d4e")
	attempts += 1
	if currentword == currentGuess:
		pass #win game
	elif attempts >= 6:
		pass #lose game
	

func load_json():
	var file = FileAccess.open(wordData, FileAccess.READ)
	if FileAccess.file_exists(wordData):
		var json_as_text = FileAccess.get_file_as_string(wordData)
#		print(json_as_text)
		var json_as_dict = JSON.parse_string(json_as_text)
#		print(json_as_dict)
		return json_as_dict


func _on_menubutton_pressed():
	$menu.visible = not $menu.visible
