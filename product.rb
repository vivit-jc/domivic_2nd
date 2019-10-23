module Product

  def refresh_unlocked_products
  	@unlocked_products = {cards: [[:growth,1]], bldgs: [], units: [:warrior]}
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

    @buildings.each do |b|
      @unlocked_products[:bldgs].delete b
    end

  end

  def set_producing_obj(obj)
  	@selected_product = @unlocked_products[obj[0]][obj[1]]
  end

  def calc_end_turn_product
  	product = @selected_product
  	if product.class == Array
  	  @product_prog[product[0]] = Array.new(10,0) unless @product_prog[product[0]]
  	  @product_prog[product[0]][product[1]] += @production_pt
  	else
  	  @product_prog[product] = 0 unless @product_prog[product]
      @product_prog[product] += get_product_and_const_pt(product)
  	end

    @production_pt = 0
    @const_pt = 0

  	if production_finished?(product)
  	  add_log("生産完了: "+product_j(@selected_product))
  	  if product.class == Array
  	    @production_pt += @product_prog[product[0]][product[1]] - product_cost(product)
  	    @trash.push Card.new(product[0],product[1])
  	    @product_prog[product[0]][product[1]] = 0
  	  else
  	    @production_pt += @product_prog[product] - product_cost(product)
  	    if BLDGDATA[product]
  	      @buildings.push product
  	    elsif UNITDATA[product]
		  @units.push product
		  @product_prog[product] = 0
  	    end
  	  end
  	  @selected_product = nil
  	end

  	refresh_unlocked_products
  end

  def production_finished?(obj)
  	if obj.class == Array
  	  return @product_prog[obj[0]][obj[1]] >= CARDDATA[obj[0]].cost[obj[1]]
    elsif UNITDATA[obj]
      return @product_prog[obj] >= UNITDATA[obj].cost
    elsif BLDGDATA[obj]
      return @product_prog[obj] >= BLDGDATA[obj].cost
    end
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

  def get_product_and_const_pt(obj)
  	if obj.class == Array or UNITDATA[obj]
  	  return @production_pt
  	else
  	  return @production_pt + @const_pt
  	end
  end

  def get_product_prog(obj)
  	if obj.class == Array 
  	  if !@product_prog[obj[0]]
  	  	return 0
  	  elsif !@product_prog[obj[0]][obj[1]]
  	  	return 0
  	  else
  	  	return @product_prog[obj[0]][obj[1]]
  	  end
    elsif !@product_prog[obj]
      return 0
    else
      return @product_prog[obj]
    end
  end

  def product_cost(obj)
  	if obj.class == Array
  	  return CARDDATA[obj[0]].cost[obj[1]]
  	elsif unit = UNITDATA[obj]
  	  return unit.cost
  	elsif bldg = BLDGDATA[obj]
  	  return bldg.cost
  	end
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