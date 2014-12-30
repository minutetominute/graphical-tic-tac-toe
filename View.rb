class View
	attr_accessor :subviews
	def initialize(subviews)
		@subviews = {}	
		@subviews = @subviews.merge(subviews)
	end
end
