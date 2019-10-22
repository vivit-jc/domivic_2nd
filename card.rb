class Card

attr_reader :num, :kind, :name
  def initialize(kind, num)
  	@kind = kind
  	@num = num
  	@name = make_name
  end

  def make_name
  	return CARDDATA[@kind].name+@num.to_s
  end

end