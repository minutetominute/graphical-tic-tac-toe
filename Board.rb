require './Cell'

class Board
	attr_accessor :image, :x, :y, :cells, :window
	def initialize(window, x, y)
		@image = Gosu::Image.new(window, Dir.pwd + "/Sprites/Board.png", true)
		@cells = []
		for i in 0..2
			@cells.push([])
			for j in 0..2
				@cells[i].push(Cell.new(self, 40 + (j)*80,  40 + (i)*80))
			end
		end
		@x = x
		@y = y	
		@window = window
	end

	def is_full?
		for x in 0 ... @cells.size
			for y in 0 ... @cells[x].size
				if @cells[x][y].contents == ""
					return false
				end
			end
		end
		return true
	end
end
