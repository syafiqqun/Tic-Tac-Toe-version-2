extends Node2D

var red_shape = preload("res://shapes/Red.tscn")
var green_shape = preload("res://shapes/Green.tscn")


var mouse_pos := Vector2(0, 0)
var box_position_pressed_in := Vector2(0, 0)

# area pos ref
var all_position_ref := []

# winning cross
var highlight_pos := Vector2(0, 0)
var highlight_rot := 0 

#// area 1|2|3
#// box  1-2-3
var current_area := 0
var current_box := 0

# player turns
var player_1 := [0, 2, 4, 6, 8]
var player_2 := [1, 3, 5, 7]

var current_turn := 0

enum shape{RED = 1, GREEN = 2}
var current_shape := 0

var board := [0, 0, 0,
			 0, 0, 0,
			 0, 0, 0]

enum state{GAME_START = 1, GAME_OVER = 2, GAME_LOOP_STOP = 3}
var game_state := 0

# player winning info
enum winner{DRAW = 0, RED_WON = 1, GREEN_WON = 2, UNDECIDED = 3}
var player_won = winner.UNDECIDED

var inside_the_area := false

enum GAME_MODE{PLAYER_VS_PLAYER = 0, AI = 1}
var current_game_mode := 0

var game_text := " == GAME OVER == \n RED WON!!!!"


func _ready():
	
	$WinningCross.hide()
	$GameOverPopup.hide()
	
	# set indicator
	$Indicator/RedGlow.color = Color(0.9, 0.07, 0.93, 1)
	$Indicator/GreenGlow.color = Color(1, 1, 1, 0.2)
	
	game_state = state.GAME_START
	
	var pos_ref = get_node("BoardPositionRef").get_children()
	for child_node in pos_ref:
		all_position_ref.append(child_node.global_position)
	print(all_position_ref)

func _input(event):
	
	if Input.is_action_just_pressed("ui_accept"):
		reset_game_data()

func _process(delta):
	
	if game_state == state.GAME_LOOP_STOP:
		return
	
	if game_state == state.GAME_OVER:
		print("GAME OVER")
		if player_won == winner.RED_WON:
			print("RED WON")
			show_highlight()
			show_game_over_popup("RED WON")
			$AudioStreamPlayer.play()
		if player_won == winner.GREEN_WON:
			print("GREEN WON")
			show_highlight()
			show_game_over_popup("GREEN WON")
			$AudioStreamPlayer.play()
		if player_won == winner.DRAW:
			print("DRAW")
			show_game_over_popup("DRAW")
		game_state = state.GAME_LOOP_STOP
	
	if current_turn == 9:
		if player_won == winner.UNDECIDED:
			print("all turn used up")
			print("game is draw")
			player_won = winner.DRAW
			game_state = state.GAME_OVER
	
	if Input.is_action_just_pressed("left_mouse_button") and inside_the_area == true:
		
		if current_turn in player_1:
			current_shape = shape.RED
			# alternating indicator
			$Indicator/GreenGlow.color = Color(0.43, 0.79, 0.45, 1)
			$Indicator/RedGlow.color = Color(1, 1, 1, 0.2)
			$AudioPlayer1.play()
		if current_turn in player_2:
			current_shape = shape.GREEN
			# alternating indicator
			$Indicator/RedGlow.color = Color(0.9, 0.07, 0.93, 1)
			$Indicator/GreenGlow.color = Color(1, 1, 1, 0.2)
			$AudioPlayer2.play()
		
		# add shape to the board
		if current_shape == 1:
			add_shape(red_shape, box_position_pressed_in)
		if current_shape == 2:
			add_shape(green_shape, box_position_pressed_in)
		
		# area check to update board state
		if current_area == 1:
			if current_box == 1:
				board[0] = current_shape
			if current_box == 2:
				board[3] = current_shape
			if current_box == 3:
				board[6] = current_shape
				
		if current_area == 2:
			current_box += 3
			if current_box == 4:
				board[1] = current_shape
			if current_box == 5:
				board[4] = current_shape
			if current_box == 6:
				board[7] = current_shape
				
		if current_area == 3:
			current_box += 6
			if current_box == 7:
				board[2] = current_shape
			if current_box == 8:
				board[5] = current_shape
			if current_box == 9:
				board[8] = current_shape
		
		# debug text
		print("Board Rep:", board)
		
		# check winning state
		
		# player 1
		check_winning_state(shape.RED, winner.RED_WON)
		# player 2
		check_winning_state(shape.GREEN, winner.GREEN_WON)
		
		# change to next player
		current_turn += 1

func show_game_over_popup(winner_player):
	$GameOverPopup.show()
	$GameOverPopup/PlayerResultText.text = winner_player

func show_highlight():
	$WinningCross.position = highlight_pos
	$WinningCross.rotation_degrees = highlight_rot
	$WinningCross.show()

func set_highlight(rot, pos):
	highlight_rot = rot
	highlight_pos = pos
	game_state = state.GAME_OVER

func add_shape(packed_scene, pos):
	var new_node = packed_scene.instance()
	new_node.global_position = pos
	get_node("ShapesContainer").add_child(new_node)

func reset_game_data():
	# reset board state
	board = [0, 0, 0, 0, 0, 0, 0, 0, 0]
	
	var shapes_delete = $ShapesContainer.get_children()
	if shapes_delete != null:
		for sd in shapes_delete:
			sd.queue_free()
	
	current_shape = 0
	current_turn = 0
	game_state = state.GAME_START
	player_won = winner.UNDECIDED
	
	# set indicator
	$Indicator/RedGlow.color = Color(0.9, 0.07, 0.93, 1)
	$Indicator/GreenGlow.color = Color(1, 1, 1, 0.2)
	$WinningCross.hide()
	$GameOverPopup.hide()

func check_winning_state(the_shape, the_winner):
	
	# horizontal
	if board[0] == the_shape and board[1] == the_shape and board[2] == the_shape:
		player_won = the_winner
		set_highlight(90, Vector2(300, 95))
	if board[3] == the_shape and board[4] == the_shape and board[5] == the_shape:
		player_won = the_winner
		set_highlight(90, Vector2(300, 225))
	if board[6] == the_shape and board[7] == the_shape and board[8] == the_shape:
		player_won = the_winner
		set_highlight(90, Vector2(300, 355))
	
	# vertical
	if board[0] == the_shape and board[3] == the_shape and board[6] == the_shape:
		player_won = the_winner
		set_highlight(0, Vector2(170, 225))
	if board[1] == the_shape and board[4] == the_shape and board[7] == the_shape:
		player_won = the_winner
		set_highlight(0, Vector2(300, 225))
	if board[2] == the_shape and board[5] == the_shape and board[8] == the_shape:
		player_won = the_winner
		set_highlight(0, Vector2(430, 225))
	
	# diagonal
	if board[0] == the_shape and board[4] == the_shape and board[8] == the_shape:
		player_won = the_winner
		set_highlight(-45, Vector2(300, 225))
	if board[2] == the_shape and board[4] == the_shape and board[6] == the_shape:
		player_won = the_winner
		set_highlight(45, Vector2(300, 225))


#======= Board Logic =======

#------ board area enter ------
func _on_Area_1_mouse_entered():
	current_area = 1
	$BoardAreaEnter/BoxArea.position = $BoardAreaEnter/AreaContainer/Area_1.position

func _on_Area_2_mouse_entered():
	current_area = 2
	$BoardAreaEnter/BoxArea.position = $BoardAreaEnter/AreaContainer/Area_2.position

func _on_Area_3_mouse_entered():
	current_area = 3
	$BoardAreaEnter/BoxArea.position = $BoardAreaEnter/AreaContainer/Area_3.position

#------ box mouse enter ------
func _on_Box1_mouse_entered():
	inside_the_area = true
	current_box = 1
	box_position_pressed_in = $BoardAreaEnter/BoxArea/Box1.global_position

func _on_Box2_mouse_entered():
	inside_the_area = true
	current_box = 2
	box_position_pressed_in = $BoardAreaEnter/BoxArea/Box2.global_position

func _on_Box3_mouse_entered():
	inside_the_area = true
	current_box = 3
	box_position_pressed_in = $BoardAreaEnter/BoxArea/Box3.global_position


func _on_Box1_mouse_exited():
	inside_the_area = false
	current_box = 0

func _on_Box2_mouse_exited():
	inside_the_area = false
	current_box = 0

func _on_Box3_mouse_exited():
	inside_the_area = false
	current_box = 0
