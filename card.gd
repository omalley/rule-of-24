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

class_name Card

enum Rank {Ace, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King}
enum Suit {Clubs, Diamonds, Hearts, Spades}

const rank_names = ["ace", "2", "3", "4", "5", "6", "7", "8", "9", "10",
 "jack", "queen", "king"]
const suit_names = ["clubs", "diamonds", "hearts", "spades"]

var rank: Rank
var suit: Suit

func _init(new_rank: Rank = Rank.Ace, new_suit: Suit = Suit.Clubs):
	rank = new_rank
	suit = new_suit

func resource_name():
	return "res://images/cards/%s_of_%s.png" % [rank_names[rank], suit_names[suit]]
