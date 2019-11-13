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

  # input [:cards/:units/:bldgs/:wonders, 上から何番目か]
  def set_producing_obj(pos)
    if pos[0] == :wonders
      @selected_product = @selectable_wonders[pos[1]]
      @selectable_wonders.delete(@selected_product)
    else
  	  @selected_product = @unlocked_products[pos[0]][pos[1]]
    end
  end

  def calc_end_turn_product
  	product = @selected_product
    init_prodoct_prog(product)
    add_point = @temp_product_pt + @coin_pt[:production] + @over_product_pt
  	if product.class == Array
  	  @product_prog[product[0]][product[1]] += add_point
  	else
      @product_prog[product] += add_point
  	end
    @temp_product_pt = 0
    @over_product_pt = 0
    @coin_pt[:production] = 0

  	if production_finished?(product)
  	  str = "生産完了: "+product_j(@selected_product)
      score_str = ""
  	  if product.class == Array
  	    @over_product_pt += @product_prog[product[0]][product[1]] - product_cost(product)
  	    @trash.push Card.new(product[0],product[1])
  	    @product_prog[product[0]][product[1]] = 0
  	  else
  	    @over_product_pt += @product_prog[product] - product_cost(product)
  	    if BLDGDATA[product]
          score_str = calc_era_mission("build_bldg")
  	      @buildings.push product
        elsif WONDERSDATA[product]
          score_str = calc_era_mission("build_wonder")
          @wonders.push product
  	    elsif UNITDATA[product]
          score_str = calc_era_mission("build_unit")
		      @units.push Unit.new(product)
		      @product_prog[product] = 0
  	    end
  	  end
      add_log(str+score_str)
  	  @selected_product = nil
  	end

  	refresh_unlocked_products
  end

  def production_finished?(obj)
    init_prodoct_prog(obj)
    if obj.class == Array
      return @product_prog[obj[0]][obj[1]] >= product_cost(obj)
    else
      return @product_prog[obj] >= product_cost(obj)
    end
  end

  # input [:cards/:units/:bldgs/:wonders, 上から何番目か]
  def product_selectable?(pos)
    return true unless pos[0] == :units # 今のところ、選ぶときに制限がかかるのはユニットのみ
    unit = @unlocked_products[pos[0]][pos[1]]
    return true if UNITDATA[unit].utype == "soldier" and soldier_selectable?
    return true if UNITDATA[unit].utype == "mount" and mount_selectable?
    return false
  end

  def soldier_selectable?
    return true if count_unit_at_utype("soldier") < get_count_bonus("soldier")
    return (count_unit_considering_bonus("soldier")+1)*3 <= sum_point_in_deck(:growth)
  end

  def mount_selectable?
    return true if count_unit_at_utype("mount") < get_count_bonus("mount")
    return (count_unit_considering_bonus("mount")+1)*7 <= @deck.size+@trash.size+@hand.size
  end

  def count_unit_considering_bonus(utype)
    return 0 if count_unit_at_utype(utype) < get_count_bonus(utype)
    return count_unit_at_utype(utype) - get_count_bonus(utype)
  end

  def init_prodoct_prog(obj)
    if obj.class == Array
      @product_prog[obj[0]] = Array.new(10,0) unless @product_prog[obj[0]]
    else
      @product_prog[obj] = 0 unless @product_prog[obj]
    end
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
  	  mes.push "タイプ: #{Unit::get_utype_j(obj)}"
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

  def sum_product_pt
    product = @selected_product
    return 0 unless product
    return get_product_prog(product)+@temp_product_pt+@coin_pt[:production]+@over_product_pt
  end

  def get_selectable_and_selected_wonders
    wonders = @selectable_wonders
    wonders.push @selected_product if WONDERSDATA[@selected_product]
    return wonders
  end

  def max_soldier
    return (sum_point_in_deck(:growth)/3).floor + get_count_bonus("soldier")
  end

  def max_mount
    return ((@deck+@trash+@hand).size/7).floor + get_count_bonus("mount")
  end

end