extends Node

# Permissions and state variables for touch input and enemy focus
var move_touch_perm = true  # Permission to move the player
var focus_on_enemy = false  # Flag indicating whether an enemy is focused

# Stores the name of the chosen player and enemy
var chosen_player = ""  # Name of the currently chosen player
var chosen_enemy = ""  # Name of the currently chosen enemy

# Dictionaries to keep track of all players and enemies
var current_players = {}  # Dictionary to hold references to current players
var current_enemies = {}  # Dictionary to hold references to current enemies

# Global counts of players and enemies
var enemy_count = 0  # Current number of enemies
var player_count = 0  # Current number of players
