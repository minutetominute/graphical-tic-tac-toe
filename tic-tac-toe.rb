require 'rubygems'
require 'gosu'
require './TextLabel'
require './Selector'
require './View'
require './Board'

class GameWindow < Gosu::Window
	def initialize
		super 640, 480, false
		self.caption = "TIC-TAC-TOE"

		#dictionary stores views for game (ie Menu and Game)
		@views = {"Menu" => View.new({"game_title" => Gosu::Font.new(self, Dir.pwd + "/Fonts/04B_30__.TTF", 48),
		"player_choice_0" => TextLabel.new(self, self.width/2, self.height/2, "1 PLAYER"),
		"player_choice_1" => TextLabel.new(self, self.width/2, self.height/2+24, "2 PLAYERS"),
		"arrow" => Selector.new(self, 220, 235)}),
		"Icon_Select" => View.new({}),	
		"Game" => View.new({"board" => Board.new(self, self.width/2, self.height/2),
					"player_turn" => TextLabel.new(self, self.width/2, self.height/5, ""),
					  "draw" => TextLabel.new(self, self.width/2, 4*self.height/5, "DRAW"),
					  "win" => TextLabel.new(self, self.width/2, 4*self.height/5, "WIN")})}
		@current_view = "Menu"		
		@num_players = 1

		@delay_timer = 0
		@select = Gosu::Sample.new(self, Dir.pwd + "/Sound\ Effects/Blip_Select.wav")
		@board_select = Gosu::Sample.new(self, Dir.pwd + "/Sound\ Effects/Board_Select.wav")
		@cell_selected = Gosu::Sample.new(self, Dir.pwd + "/Sound\ Effects/Cell_Selected.wav")
		@enter = Gosu::Sample.new(self, Dir.pwd + "/Sound\ Effects/Enter.wav")
		@music = Gosu::Song.new(self, Dir.pwd + "/Music/Azureflux_-_02_-_Popcorn_Blast.mp3")
		@active_cell = [0, 0]
		@game_status = ["", ""]
		@players = []
		@current_player = 0
	end

	def update
		if @current_view == "Menu"
			if ((button_down? Gosu::KbDown) || (button_down? Gosu::KbUp)) && (@delay_timer > 10) 
				@select.play
				@views["Menu"].subviews["arrow"].current_selection = 
					(@views["Menu"].subviews["arrow"].current_selection + 1) % 2
				@views["Menu"].subviews["arrow"].x = @views["Menu"].subviews["player_choice_" + 
																 @views["Menu"].subviews["arrow"].current_selection.to_s].x - 100 
				@views["Menu"].subviews["arrow"].y = @views["Menu"].subviews["player_choice_" + 
																 @views["Menu"].subviews["arrow"].current_selection.to_s].y - 5 
				@delay_timer = 0
			end
			if button_down? Gosu::KbReturn
				@enter.play
				@current_view = "Game"
				@num_players = @views["Menu"].subviews["arrow"].current_selection + 1
				if @num_players == 1
					@players = [["Player 1", "X"], ["Computer", "O"]]
				elsif @num_players == 2
					@players = [["Player 1", "X"], ["Player 2", "O"]]
				end
				@delay_timer = 0
			end
		elsif @current_view == "Game"
			if @delay_timer > 10 && @game_status == ["", ""] && 
				(@players[@current_player][0] == "Player 1" || 
				@players[@current_player][0] == "Player 2")
				if button_down? Gosu::KbUp
					@views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].reset_cell
					@board_select.play
					move_active_cell("up")
					@delay_timer = 0
				end
				if button_down? Gosu::KbDown
					@views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].reset_cell
					move_active_cell("down")
					@board_select.play
					@delay_timer = 0
				end
				if button_down? Gosu::KbRight
					@views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].reset_cell
					move_active_cell("right")
					@board_select.play
					@delay_timer = 0
				end
				if button_down? Gosu::KbLeft
					@views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].reset_cell
					move_active_cell("left")
					@board_select.play
					@delay_timer = 0
				end
				if button_down? Gosu::KbReturn
					@cell_selected.play
					@views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].contents = @players[@current_player][1] 
					@views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].reset_cell
					move_active_cell("right")
					@delay_timer = 0
					@game_status = self.check_game_status(@views["Game"].subviews["board"])
					@current_player = (@current_player + 1) % 2
				end
			elsif @players[@current_player][0] == "Computer" && 
				@game_status == ["", ""] && @delay_timer > 30
				@cell_selected.play
				@views["Game"].subviews["board"]
                      .cells[@active_cell[0]][@active_cell[1]].reset_cell
				@active_cell = get_computer_move(@views["Game"].subviews["board"])
				@views["Game"].subviews["board"]
                      .cells[@active_cell[0]][@active_cell[1]].contents = @players[@current_player][1] 
				@views["Game"].subviews["board"]
                      .cells[@active_cell[0]][@active_cell[1]].reset_cell
                move_active_cell("right")
                @delay_timer = 0
                @game_status = self.check_game_status(@views["Game"].subviews["board"])
				@current_player = (@current_player + 1) % 2
			end
		end
	end

	def draw
		@music.play
		if @current_view == "Menu"
			@views["Menu"].subviews["game_title"].draw_rel(
				"TIC-TAC-TOE", self.width/2, self.height/3, 0, rel_x = 0.5, 
				rel_y = 0.5, factor_x = 1, factor_y = 1, color = 0xffffffff, mode = :default) 
			
			@views["Menu"].subviews["player_choice_0"].font.draw_rel(
				@views["Menu"].subviews["player_choice_0"].text, 
				@views["Menu"].subviews["player_choice_0"].x, 
				@views["Menu"].subviews["player_choice_0"].y, 0, rel_x = 0.5, rel_y = 0.5)
			
			@views["Menu"].subviews["player_choice_1"].font.draw_rel(
				@views["Menu"].subviews["player_choice_1"].text, 
				@views["Menu"].subviews["player_choice_1"].x, 
				@views["Menu"].subviews["player_choice_1"].y, 0, rel_x = 0.5, rel_y = 0.5)

			@views["Menu"].subviews["arrow"].image.draw(@views["Menu"].subviews["arrow"].x, @views["Menu"].subviews["arrow"].y, 0, factor_x = 1, factor_y = 1)
			
		elsif @current_view == "Game"
			@views["Game"].subviews["board"].image.draw_rot(@views["Game"].subviews["board"].x, 
															@views["Game"].subviews["board"].y, 
															0, center_x = 0.5, center_y = 0.5)
			self.draw_cells_on_board(@views["Game"].subviews["board"])
			if @delay_timer % 15 == 0
				if @views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].image == nil
					@views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].image = 
						Gosu::Image.new(self, Dir.pwd + "/Sprites/Cell_Selected.png", true)
				elsif @views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].contents == "X" || 
					   @views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].contents == "O"	
					@views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].image = 
						Gosu::Image.new(self, Dir.pwd + "/Sprites/" + 
										@views["Game"].subviews["board"]
					                      .cells[@active_cell[0]][@active_cell[1]].contents +
											  ".png", true)
				else
					@views["Game"].subviews["board"]
					.cells[@active_cell[0]][@active_cell[1]].image = nil
				end
			end
			if @game_status != ["", ""]
				if @game_status[1] == "draw" 
					 @views["Game"].subviews[@game_status[1]].font.draw_rel(@views["Game"]
								.subviews[@game_status[1]].text, 
									@views["Game"].subviews[@game_status[1]].x, 
									@views["Game"].subviews[@game_status[1]].y, 0, 
									rel_x = 0.5, rel_y = 0.5)
				else
					@views["Game"].subviews[@game_status[1]].text = @game_status[0] + " WINS!"	
					@views["Game"].subviews[@game_status[1]].font.draw_rel(@views["Game"]
                                  .subviews[@game_status[1]].text, 
                                      @views["Game"].subviews[@game_status[1]].x, 
                                      @views["Game"].subviews[@game_status[1]].y, 0, 
                                      rel_x = 0.5, rel_y = 0.5)
				end
			else
			@views["Game"].subviews["player_turn"].text = @players[@current_player][0] + "'S TURN!"	
			@views["Game"].subviews["player_turn"].font.draw_rel(@views["Game"]
                                    .subviews["player_turn"].text, 
                                        @views["Game"].subviews["player_turn"].x, 
                                        @views["Game"].subviews["player_turn"].y, 0, 
                                        rel_x = 0.5, rel_y = 0.5)	
			end
		end
		@delay_timer += 1
	end
	
	def draw_cells_on_board(board)
		for x in 0 ... board.cells.size
			for y in 0 ... board.cells[0].size
				if @views["Game"].subviews["board"]
									.cells[x][y].image != nil
					@views["Game"].subviews["board"]
					.cells[x][y].image.draw_rot(@views["Game"].subviews["board"]
					.cells[x][y].x + @views["Game"].subviews["board"].x - 
						@views["Game"].subviews["board"].image.width/2, 
					@views["Game"].subviews["board"]
					.cells[x][y].y + @views["Game"].subviews["board"].y - 
						@views["Game"].subviews["board"].image.height/2,
					   	0, center_x = 0.5, center_y = 0.5)
				end
			end

		end

	end

	def check_game_status(board)
		winning_options = []

		for x in 0 ... board.cells.size
			winning_options.push([board.cells[0][x], board.cells[1][x], board.cells[2][x]])
		end

		for y in 0 ... board.cells[0].size
			winning_options.push([board.cells[y][0], board.cells[y][1], board.cells[y][2]])
		end

		winning_options.push([board.cells[0][0], board.cells[1][1], board.cells[2][2]])
		winning_options.push([board.cells[0][2], board.cells[1][1], board.cells[2][0]])

		winning_options.each do |i|
			if i[0].contents == i[1].contents && 
				i[1].contents == i[2].contents && 
				i[0].contents != "" 
					winning_player = ""
				@players.each do |j|
					if j[1] == i[0].contents
						return [j[0], "win"]
					end
				end
			end
		end

		if board.is_full? && @game_status[1] != "win" 
			return ["", "draw"]
		end
		return ["", ""]
	end

	def move_active_cell(move)
		next_empty_cell = []
		index = @active_cell
		counter = 0
		while next_empty_cell == []
			if move == "right"
				index = [index[0], (index[1] + 1) % 3]
				if @views["Game"].subviews["board"].cells[index[0]][index[1]].contents == "" && 
					index != @active_cell
					next_empty_cell = index
				else
					if index == @active_cell 
						move = "down"
					end
				end
			elsif move == "left"
				index = [index[0], (index[1] - 1) % 3]
				if @views["Game"].subviews["board"].cells[index[0]][index[1]].contents == "" && 
					index != @active_cell
					next_empty_cell = index
				else
					if index == @active_cell 
						move = "up"
					end
				end
			elsif move == "up"
				index = [(index[0] - 1) % 3, index[1]]
				if @views["Game"].subviews["board"].cells[index[0]][index[1]].contents == "" && 
					index != @active_cell
					next_empty_cell = index
				else
					if index == @active_cell 
						move = "right"
					end
				end
			elsif move == "down"
				index = [(index[0] + 1) % 3, index[1]]
				if @views["Game"].subviews["board"].cells[index[0]][index[1]].contents == ""  && 
					index != @active_cell
					next_empty_cell = index
				else
					if index == @active_cell 
						move = "left"
					end
				end
			end
			if counter >= 20
				next_empty_cell = @active_cell
			end
			counter += 1
		end
		@active_cell = next_empty_cell
	end

	def get_computer_move(board)
		return get_available_moves(board).sample	
	end

	def get_available_moves(board)
		moves = []
		for x in 0 ... board.cells.size
			for y in 0 ... board.cells[x].size
				if board.cells[x][y].contents == ""
					moves.push([x, y])
				end
			end
		end	
		return moves	
	end

end

window = GameWindow.new
window.show
