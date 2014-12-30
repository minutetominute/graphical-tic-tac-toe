class Selector
	attr_accessor :current_selection, :image, :x, :y
	def initialize(window, x, y)
		@image = Gosu::Image.new(window, Dir.pwd + "/Sprites/Arrow.png", false)
		@x = x
		@y = y
		@current_selection = 0
	end

end

