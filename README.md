# Rule of 24

A math card game by Owen O'Malley

## Rules:

The player must create an expression that equals 24 using exactly the
four numbers represented by the cards. Expressions may use +, -, *, or
/ as well as parentheses for grouping. All math is done with integers,
so all division is rounded down (eg. 2/3 = 0 and 3/2 = 1). The program
will automatically re-shuffle problems that are unsolvable.

Cards are translated to numbers as:
* Ace = 1
* 2 to 10 = 2 to 10
* Jack = 11
* Queen = 12
* King = 13

# Examples:

* 1 * 2 * 3 * 4 = 24
* 12 * 11 / 4 / 3 = 11
* 12 * (11 / 4) / 3 = 8
* 12 * ((11 / 4) / 3) = 0
* 12 * (11 / ( 4 / 3)) = 132

## Includes:

* rule-of-24:
  * GPL v3
  * <https://github.com/omalley/rule-of-24>
* vector-play-cards:
  * public domain
  * <https://code.google.com/archive/p/vector-playing-cards/downloads>
