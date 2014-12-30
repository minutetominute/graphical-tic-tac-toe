class TextLabel
	attr_accessor :font, :x, :y, :text
	def initialize(window, x, y, text)
		@font = Gosu::Font.new(window, Dir.pwd + "/Fonts/04B_30__.TTF", 24)
		@x = x 
		@y = y
		@text = text
	end
end
