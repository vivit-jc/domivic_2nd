class Unit

attr_reader :kind, :name, :att, :def, :active, :selected, :utype, :utype_j

  def initialize(kind)
  	@kind = kind
  	@name = UNITDATA[kind].name
  	@att = UNITDATA[kind].att
  	@def = UNITDATA[kind].def
    @utype = UNITDATA[kind].utype
  	@utype_j = Unit::get_utype_j(@kind)
  	@active = true
  	@selected = false
  end

  def self.get_utype_j(kind)
  	case UNITDATA[kind].utype
  	when "soldier"
  	  return "兵士"
  	when "mount"
  	  return "騎馬"
  	when "siege"
  	  return "攻城"
  	when "defender"
  	  return "防衛"
  	end
  end

end