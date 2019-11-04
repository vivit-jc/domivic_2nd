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
    if obj[0] == :wonders
      @selected_product = @selectable_wonders[obj[1]]
      @selectable_wonders.delete(@selected_product)
    else
  	  @selected_product = @unlocked_products[obj[0]][obj[1]]
    end
  end

  def calc_end_turn_product
  	product = @selected_product
  	if product.class == Array
  	  @product_prog[product[0]] = Array.new(10,0) unless @product_prog[product[0]]
  	  @product_prog[product[0]][product[1]] += @production_pt + @coin_pt[:production]
  	else
  	  @product_prog[product] = 0 unless @product_prog[product]
      @product_prog[product] += @production_pt + @coin_pt[:production]
  	end

    @production_pt = 0
    @coin_pt[:production] = 0

  	if production_finished?(product)
  	  str = "生産完了: "+product_j(@selected_product)
      score_str = ""
  	  if product.class == Array
  	    @production_pt += @product_prog[product[0]][product[1]] - product_cost(product)
  	    @trash.push Card.new(product[0],product[1])
  	    @product_prog[product[0]][product[1]] = 0
  	  else
  	    @production_pt += @product_prog[product] - product_cost(product)
  	    if BLDGDATA[product]
          score_str = calc_era_mission("build_bldg")
  	      @buildings.push product
        elsif WONDERSDATA[product]
          score_str = calc_era_mission("build_wonder")
          @buildings.push product
  	    elsif UNITDATA[product]
          score_str = calc_era_mission("build_unit")
		      @units.push product
		      @product_prog[product] = 0
  	    end
  	  end
      add_log(str+score_str)
  	  @selected_product = nil
  	end

  	refresh_unlocked_products
  end

  def production_finished?(obj)
    return @product_prog[obj] >= product_cost(obj)
  end

  def make_product_text(obj)
  	mes = []

    # 生産物データが書きかけなので、無ければreturn あとで消す
    return mes if (obj.class == Array and !CARDDATA[obj[0]]) and !UNITDATA[obj] and !BLDGDATA[obj] and !WONDERSDATA[obj]

    mes.push product_j(obj)

  	if obj.class == Array
  	  mes.push CARDDATA[obj[0]][:text]
  	elsif unit = UNITDATA[obj]
  	  mes.push "攻撃力: #{unit.att} 防御力: #{unit.def}"
  	  mes.push "タイプ: #{utype_j(unit.utype)}"
  	elsif bldg = BLDGDATA[obj]
  	  mes.push bldg.text
    elsif wonder = WONDERSDATA[obj]
      mes.push wonder.text
  	end

  	return mes
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
    # 軽減効果などを含めた結果を返す
  	if obj.class == Array
  	  return CARDDATA[obj[0]].cost[obj[1]]
  	elsif UNITDATA[obj]
  	  return UNITDATA[obj].cost
  	elsif BLDGDATA[obj]
  	  cost_down = 0
  	  cost_down += 10 if tech_finished?(:masonry)
  	  return (BLDGDATA[obj].cost*(100-cost_down)/100).round
    elsif WONDERSDATA[obj]
      return WONDERSDATA[obj].cost
  	end
  end

  def product_j(obj)
  	if obj.class == Array
      return CARDDATA[obj[0]][:name] if obj[1] == 0
  	  return CARDDATA[obj[0]][:name]+obj[1].to_s
  	elsif unit = UNITDATA[obj]
  	  return unit.name
  	elsif bldg = BLDGDATA[obj]
  	  return bldg.name
    elsif wonder = WONDERSDATA[obj]
      return wonder.name
  	end
  end

  def utype_j(utype)
  	case utype
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