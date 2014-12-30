class Cell
	attr_accessor :image, :x, :y, :contents
	#x and y are relative to the top left corner of the board
	def initialize(board, x, y)
		@board = board
		@x = x 
		@y = y
		@contents = ""
		@image = nil
	end

	def reset_cell
		if @contents == ""
			@image = nil
		else
			@image = Gosu::Image.new(@board.window, Dir.pwd + "/Sprites/" + 
				@contents + ".png", true)	
		end
	end
	
end
