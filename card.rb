class Card

attr_reader :num, :kind, :name
  def initialize(kind, num)
  	@kind = kind
  	@num = num
  	@name = make_name

  end

  def make_name
  	namedata = [
  	  [:science, "研究"],
  	  [:growth, "成長"],
  	  [:production, "生産"],
  	  [:culture, "文化"],
  	  [:autority, "権威"],
      [:inheritance, "継承"],
      [:trade, "交易"],
      [:construction, "建築"]
  	]
  	namedata.each do |sym,j|
  	  return j+@num.to_s if sym == @kind
  	end
  end

end