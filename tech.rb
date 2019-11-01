module Tech

  def calc_end_turn_tech
    @tech_prog[@selected_tech] += @temp_research_pt + @coin_pt[:science]
    @coin_pt[:science] = 0
    # 研究完了処理
    if tech_finished?(@selected_tech)
      add_log("研究完了: "+tech_j(@selected_tech))
      # 研究ポイントの溢れ処理
      @temp_research_pt = @tech_prog[@selected_tech] - tech_cost(@selected_tech)
      @tech_prog[@selected_tech] = tech_cost(@selected_tech)
      
      # 技術データが書きかけなので、無ければここでreturn あとで消す
      return unless TECHDATA[@selected_tech.to_s]
      
      # 研究完了時にタイルがもらえる処理
      if cards = TECHDATA[@selected_tech.to_s]["finish_card"]
        cards.each do |t|
          card = Card.new(t[0],t[1])
          @trash.push card
        end
      end
      @selected_tech = nil
    else
      @temp_research_pt = 0
    end
  end

  def set_researching_tech(sym)
    @selected_tech = sym
  end

  def get_tech_sym_from_xy(xy)
    return @tech_array[xy[0]][xy[1]][0]
  end

  def get_tech_xy_from_sym(sym)
    @tech_array.each_with_index do |array,row|
      if col = array.map{|e|e[0]}.index(sym)
        return [row,col]
      end
    end
  end

  def tech_era(sym)
    @tech_array.each_with_index do |t,i|
      return i if t.flatten.include?(sym)
    end
  end

  def tech_cost(sym)
    return [4,10,18,28,40,54][tech_era(sym)]
  end

  def tech_finished?(sym)
    return @tech_prog[sym] >= tech_cost(sym)
  end

  def tech_selectable?(sym)
    return true if tech_era(sym) == 0
    col = get_tech_xy_from_sym(sym)[1]
    check_techs = @tech_array[tech_era(sym)-1]
    if tech_era(sym)%2 == 0
      return tech_finished?(check_techs[col][0]) || tech_finished?(check_techs[col+1][0])
    else
      if col == 0
        return tech_finished?(check_techs[col][0])
      elsif col == 6
        return tech_finished?(check_techs[col-1][0])
      else
        return tech_finished?(check_techs[col][0]) || tech_finished?(check_techs[col-1][0])
      end
    end
  end

  def tech_j(sym)
    return @flat_tech_array.find{|e|e[0] == sym}[1]
  end

  def make_tech_text(sym)
    mes = []
    mes.push tech_j(sym)

    # 技術データが書きかけなので、無ければreturn あとで消す
    return mes unless TECHDATA[sym.to_s]

    [
      ["finish_card","カードを取得: "],
      ["unlock_card","カードを解禁: "],
      ["unlock_bldg","建物を解禁: "],
      ["unlock_unit","ユニットを解禁: "],
      ["effect","効果: "]
    ].each do |e,j|
      if TECHDATA[sym.to_s][e]
        mes.push j+TECHDATA[sym.to_s][e].to_s
      end
    end
    return mes
  end

end