# Rule of 24, a math card game
# Copyright by Owen O'Malley 2024
# 
# This software is licensed under GPL v3:
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License.
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# A copy of the GNU General Public License is at
# <https://www.gnu.org/licenses>.

extends Control

@onready var controls = $Margin
@onready var status = $Margin/VBoxContainer/StatusBox/Status
@onready var card_slots = $Margin/VBoxContainer/Cards.get_children()
@onready var expression = $Margin/VBoxContainer/InputBox/Expression
@onready var help_panel = $HelpPanel
@onready var help_box = $HelpPanel/HelpMargin

# The property name that we use to store the card information on the image.
const card_property = StringName("card")

# The array of the deck images.
var card_deck = Array()
# Regex to match invalid characters.
var invalid_regex = RegEx.new()
# Regex to match each token
var token_regex = RegEx.new()
# The set of unsolvable inputs
var unsolvable

# Called when the node enters the scene tree for the first time.
func _ready():
	invalid_regex.compile(r'[^- 0-9+*/()]')
	token_regex.compile(r'[0-9]+|[-+*/()]')
	unsolvable = load_int_set("res://data/unsolvable.json")
	clear()
	create_deck()
	shuffle()
	# Adjust the control sizes
	size_changed()

var has_virtual_keyboard = DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)
var has_windows = DisplayServer.has_feature(DisplayServer.FEATURE_SUBWINDOWS)
var current_keyboard = 0

func _process(_delta):
	# detect when the keyboard changed state
	if has_virtual_keyboard:
		var new_keyboard = DisplayServer.virtual_keyboard_get_height();
		if new_keyboard != current_keyboard:
			current_keyboard = new_keyboard
			size_changed()

func size_changed():
	if controls != null && help_box != null:
		if not has_windows:
			# Set the controls to use the safe area, which avoids the cutouts.
			var safe = DisplayServer.get_display_safe_area()
			controls.set_size(Vector2(safe.size.x, safe.size.y - current_keyboard))
			controls.set_position(safe.position)
		# Set the help window to the same size & position.
		help_panel.position = controls.position
		help_box.set_custom_minimum_size(controls.size)
		# Cause the system to reevalute the help popup size.
		help_panel.size = Vector2.ZERO
		help_box.update_minimum_size()

# Load a json document as a dictionary of int arrays.
# Used for loading the unsolvable inputs.
func load_int_set(path: String):
	var result = Dictionary()
	for row in load(path).data:
		var int_row = Array()
		for val in row:
			int_row.push_back(val as int)
		result[int_row] = null
	return result

# Clear the text fields
func clear():
	status.text = ""
	expression.text = ""

# Loads all of the card images into a list.
func create_deck():
	for rank in Card.Rank.values():
		for suit in Card.Suit.values():
			var card = Card.new(rank, suit)
			var texture = load(card.resource_name())
			# Label each card with its rank and suit.
			texture.set_meta(card_property, card)
			card_deck.push_back(texture)

# The user pushed the shuffle button.
func shuffle():
	clear()
	while true:
		card_deck.shuffle()
		for i in range(card_slots.size()):
			card_slots[i].texture = card_deck[i]
		var inputs = get_inputs()
		inputs.sort()
		if not unsolvable.has(inputs):
			break
		print(inputs, " is unsolvable. trying again.")

# The user pushed the verify button
func verify():
	var nums = get_inputs()
	var tokens = tokenize(expression.text)
	if typeof(tokens) == TYPE_STRING:
		status.text = tokens
	else:
		var answer = parse_expression(tokens, nums)
		if typeof(answer) == TYPE_STRING:
			status.text = answer
		elif answer == 24:
			status.text = "Correct"
		else:
			status.text = "%s is incorrect" % answer

# The user pressed return on the expression.
func expression_changed(_new_text: String):
	verify()

# Get the numbers that correspond to all of the cards.
func get_inputs():
	var result = Array()
	for slot in card_slots:
		result.push_back(slot.texture.get_meta(card_property).rank + 1)
	return result

# Break string into tokens, returning the list of tokens or an error message.
func tokenize(input: String):
	var result = invalid_regex.search(input)
	if result:
		return "Invalid character '%s'" % result.get_string()
	var token_list = Array()
	for word in token_regex.search_all(input):
		token_list.push_back(word.get_string())
	return token_list

# Parse and evaluate the expression or return an error message.
func parse_expression(tokens: Array, numbers: Array):
	var result = parse_term(tokens, numbers)
	if typeof(result) == TYPE_STRING:
		return result
	if not tokens.is_empty():
		return "Invalid expression at %s" % tokens.front()
	if not numbers.is_empty():
		return "Not all numbers in set were used (eg %s)." % numbers.front()
	return result

# Parse a series of + and - operators.
func parse_term(tokens: Array, numbers: Array):
	var left = parse_factor(tokens, numbers)
	if typeof(left) == TYPE_STRING:
		return left
	var result = left
	var next = tokens.front()
	while next == "+" || next == "-":
		tokens.pop_front()
		var right = parse_factor(tokens, numbers)
		if typeof(right) == TYPE_STRING:
			return right
		if next == "+":
			result += right
		else:
			result -= right
		next = tokens.front()
	return result

# Parse a series of * and / operators
func parse_factor(tokens: Array, numbers: Array):
	var left = parse_primary(tokens, numbers)
	if typeof(left) == TYPE_STRING:
		return left
	var result = left
	var next = tokens.front()
	while next == "*" || next == "/":
		tokens.pop_front()
		var right = parse_primary(tokens, numbers)
		if typeof(right) == TYPE_STRING:
			return right
		if next == "*":
			result *= right
		else:
			if right == 0:
				return "Division by 0"
			result /= right
		next = tokens.front()
	return result

# Parse numbers or parentheses.
func parse_primary(tokens: Array, numbers: Array):
	var token = tokens.pop_front()
	if token == null:
		return "Incomplete expression"
	if token == "(":
		var result = parse_term(tokens, numbers)
		if typeof(result) == TYPE_STRING:
			return result
		token = tokens.pop_front()
		if token != ")":
			return 'Mismatched parentheses'
		return result
	else:
		if not token.is_valid_int() || token.length() > 3:
			return 'Parse error at %s' % token
		var val = token.to_int()
		if not numbers.has(val):
			return "%s isn't in the cards" % val
		numbers.erase(val)
		return val
