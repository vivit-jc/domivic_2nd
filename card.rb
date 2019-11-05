class Card

attr_reader :num, :kind, :name
  def initialize(kind, num)
  	@kind = kind
  	@num = num
  	@name = make_name
  end

  def make_name
    return CARDDATA[@kind].name if @num == 0
  	return CARDDATA[@kind].name+@num.to_s
  end

  def action?
    return CARDDATA[@kind].action
  end

  def instant?
    return CARDDATA[@kind].instant
  end

  def data
    return CARDDATA[@kind]
  end

end