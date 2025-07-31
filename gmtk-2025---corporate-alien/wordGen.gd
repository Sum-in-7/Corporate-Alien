extends Node2D

var firstLetter: String
var finalWord : String
const charsC = 'qwrtypsdfghjklzxcvbnm    '
const charsV = 'aeiou'
const uppercaseChars = 'QWERTYUIOPASDFGHJKLZXCVBNM'
var wordBank = []

func _on_timer_timeout() -> void:
	finalWord = generateNewWord(firstLetter, charsC, charsV, uppercaseChars)
	wordBank.append(finalWord)
	$Label.set_text (finalWord)

func generateNewWord(firstLetter, charsC, charsV, uppercaseChars):
	firstLetter = uppercaseChars[randi() % 26]
	var currentLetter = firstLetter
	var nextLetter : String
	var consonantCount =0; var vowelCount=0; var cOrV
	var word = firstLetter
	
	for n in (randi() % 10 + 2):
		
		if consonantCount == 3:
			cOrV = 1
			consonantCount = 0
		elif vowelCount == 2:
			cOrV = 0
			vowelCount = 0
		else:
			cOrV = randi() % 2
			
		if cOrV == 0:
			nextLetter = charsC[randi() % 25]
			consonantCount+=1
		else:
			nextLetter = charsV[randi()%4]
			vowelCount +=1
		
		word += nextLetter
	return word
