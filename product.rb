module Product

  def refresh_unlocked_products
  	@unlocked_products = {cards: [], bldgs: [], units: []}
    @flat_tech_array.each do |tech,j|
      if tech_finished?(tech)
      	cards = TECHDATA[tech][:unlock_card]
      	bldgs = TECHDATA[tech][:unlock_bldg]
      	units = TECHDATA[tech][:unlock_unit]
      	
      	@unlocked_products[:cards] += cards if cards
      	@unlocked_products[:bldgs] += bldgs if bldgs
      	@unlocked_products[:units] += units if units  	
      end
    end
  end

  def set_producing_obj(obj)
  	@selected_product = @unlocked_products[obj[0]][obj[1]]
  end

  def calc_end_turn_product
  	refresh_unlocked_products
  end

  def make_product_text(obj)
  	mes = []

    # 生産物データが書きかけなので、無ければreturn あとで消す
    return mes if (obj.class == Array and !CARDDATA[obj[0]]) and !UNITDATA[obj] and !BLDGDATA[obj]

    mes.push product_j(obj)

  	if obj.class == Array
  	  mes.push CARDDATA[obj[0]][:text]
  	elsif unit = UNITDATA[obj]
  	  mes.push "攻撃力: #{unit.att} 防御力: #{unit.def}"
  	  mes.push "タイプ: #{utype_j(unit.utype)}"
  	elsif bldg = BLDGDATA[obj]
  	  mes.push bldg.text
  	end

  	return mes
  end

  def product_j(obj)
  	if obj.class == Array
  	  return CARDDATA[obj[0]][:name]+obj[1].to_s
  	elsif unit = UNITDATA[obj]
  	  return unit.name
  	elsif bldg = BLDGDATA[obj]
  	  return bldg.name
  	end
  end

  def utype_j(utype)
  	if utype == "soldier"
  	  return "兵士"
  	elsif utype == "mount"
  	  return "騎馬"
  	elsif utype == "siege"
  	  return "攻城"
  	elsif utype == "defender"
  	  return "防衛"
  	end
  end

end