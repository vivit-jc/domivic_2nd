class View

  def initialize(game,controller)
    @game = game
    @controller = controller

    @view_status_buff = nil

    @cardback = Image.new(60,60)
    @cardback.box_fill(0,0,60,60,DARKGRAY)
    @actioncardback = Image.new(60,60)
    @actioncardback.box_fill(0,0,60,60,DARKBLUE)    
    @unitback = Image.new(60,60)
    @unitback.box_fill(0,0,60,60,DARKRED)  
    @buttonback = Image.new(170,70)
    @buttonback.box_fill(0,0,170,70,YELLOW)
    @tech_panel_back = Image.new(160,70)
    @tech_panel_back.box_fill(0,0,160,70,DARKGRAY)
    @const_panel_back = Image.new(160,70)
    @const_panel_back.box_fill(0,0,160,70,DARKGRAY)
    @deckinfoback = Image.new(80,480)
    @trashinfoback = Image.new(80,480)
    @erainfoback = Image.new(310,201)
    @bldginfoback = Image.new(200,480)

    @tech_array = @game.tech_array
    @flat_tech_array = @game.flat_tech_array
    @tech_back = {}
    @flat_tech_array.map{|e|e[0]}.each do |e|
      @tech_back[e] = Image.new(40,40)
    end
    @tech_view_back_button_back = Image.new(160,20)
    @tech_view_back_button_back.box_fill(0,0,160,20,DARKGRAY)

    @growth_gage = Image.new(100,10)
    @great_person_gage = Image.new(100,10)
    @research_gage = Image.new(150,10)
    @production_gage = Image.new(150,10)
  end

  def draw
    draw_xy
    draw_debug
    case @game.status
    when :title
      draw_title
    when :game
      draw_game
    when :stats
      draw_stats
    end
  end

  def draw_title
    Window.draw(0,0,Image[:title])
    Window.draw_font(30, 240, "DOMIVIC", Font50, {color: YELLOW})
    
    TITLE_MENU_TEXT.each_with_index do |menu,i|
      Window.draw_font(TITLE_MENU_X,TITLE_MENU_Y[i],menu,Font32,mouseover_color(@controller.pos_title_menu == i, YELLOW)) 
    end
  end

  def draw_game
    if Input.mouse_push?( M_LBUTTON )
      refresh_gages
      refresh_back
    end
    if @game.view_status == :tech_view
      refresh_tech_view if @view_status_buff != :tech_view
      @view_status_buff = :tech_view
      draw_tech_view
    elsif @game.view_status == :product_view
      refresh_product_view if @view_status_buff != :product_view
      @view_status_buff = :product_view
      draw_product_view
    elsif @game.view_status == :log_view
      draw_log_view
    else
      @view_status_buff = :main_view
      draw_hand
      draw_rightside
      draw_leftside
      draw_units
      draw_bottom
      draw_rightside_info
      draw_leftside_info
      draw_log
    end

  end

  def draw_hand
    case @game.click_mode
    when :select_invasion_bonus
      @game.invasion_bonus[0].each_with_index do |e,i|
        Window.draw_font(RIGHT_SIDE_WIDTH,5+i*22,make_bonus_str(i),Font20)
      end
      return
    when :select_great_person_bonus
      draw_great_person_bonus
      return
    when :select_wonder_from_engineer
      wonders = @game.get_selectable_and_selected_wonders
      wonders.each_with_index do |w,i|
        Window.draw_font(RIGHT_SIDE_WIDTH,5+i*22,WONDERSDATA[w].name,Font20)
      end
      return
    end
    
    @game.hand.each_with_index do |card,i|
      x = RIGHT_SIDE_WIDTH+(i%5)*65
      y = 5+65*(i/5).floor
      back = (card.action? and @game.action_pt > 0) ? @actioncardback : @cardback
      Window.draw(x,y,back)
      Window.draw(x+2,y+2,Image[card.kind])
      Window.draw_font(x+2,y+38,card.name,Font16)
      next if card.kind == :cancel
      Window.draw_font(x+45,y+3,"★",Font12) if card.action? and @game.action_pt > 0
      Window.draw_font(x+45,y+3,"◎",Font12) if card.instant?
      
    end
  end

  def draw_units
    @game.units.each_with_index do |unit,i|
      x = RIGHT_SIDE_WIDTH+(i%5)*65
      y = UNITS_Y+65*(i/5).floor
      Window.draw(x,y,@unitback)
      Window.draw(x+2,y+2,Image[unit.kind.to_sym])
      str = i == @game.delete_unit ? "削除？" : "#{unit.att}/#{unit.def}"
      Window.draw_font(x+2,y+38,str,Font16)
    end
  end

  def draw_rightside
    Window.draw(5,5,Image[:deck])
    Window.draw(47,5,Image[:trash])
    Window.draw_font(8,42,sprintf("% 2d",@game.deck.size),Font20)
    Window.draw_font(49,42,sprintf("% 2d",@game.trash.size),Font20)
    Window.draw(5,62,Image[:growth])
    Window.draw_font(45,65,"Lv#{@game.growth_level}",Font16)
    Window.draw_font(45,83,"#{@game.growth_pt}/#{@game.growth_level*4-2}",Font16)
    Window.draw(5,100,@growth_gage)
    Window.draw(5,115,Image[:greatperson])
    Window.draw_font(45,135,"#{@game.great_person_pt}/#{@game.get_next_great_person_pt}",Font16)
    Window.draw(5,153,@great_person_gage)

    Window.draw(5,170,Image[:construction])
    Window.draw(47,170,Image[:money_bag])
    Window.draw_font(8,205,sprintf("% 2d",(@game.buildings.size+@game.wonders.size)),Font20)
    Window.draw_font(45,205,sprintf("% 2d",@game.coin),Font20)

    Window.draw(5,240,Image[:emblem])
    Window.draw(47,240,Image[:culture])
    Window.draw_font(8,280,sprintf("% 2d",@game.emblems.size),Font20)
    Window.draw_font(45,280,sprintf("% 2d",@game.culture_pt+@game.temp_culture_pt),Font20)
    
  end

  def draw_leftside
    Window.draw_font(LEFT_SIDE_X+20,5,"【#{era_j}】",Font28)
    Window.draw_font(LEFT_SIDE_X,40,"ターン #{@game.turn}/#{(@game.era+1)*TURN_ERA}",Font20)
    Window.draw_font(LEFT_SIDE_X,62,"時代スコア #{@game.era_score}",Font20)
    Window.draw_font(LEFT_SIDE_X,84,"属州 #{@game.province}",Font20)
    Window.draw_font(LEFT_SIDE_X,106,"脅威Lv #{@game.threat}",Font20)
    Window.draw(LEFT_SIDE_X,BOTTOM_Y,@buttonback)
    if @game.selectable_turn_end? and @game.exist_defense_event?
      Window.draw_font(LEFT_SIDE_X+14,BOTTOM_Y+23,"防衛イベント",Font24,{color: C_BLACK}) 
    elsif @game.selectable_turn_end?
      Window.draw_font(LEFT_SIDE_X+14,BOTTOM_Y+23,"ターン終了",Font28,{color: C_BLACK}) 
    else
      Window.draw_font(LEFT_SIDE_X+14,BOTTOM_Y+23,@game.need_to_turn_end_mes,Font16,{color: C_BLACK}) 
    end

  end

  def draw_bottom
    #make_bottom_panel(160,70,:tech_panel,@tech_panel_back)
    Window.draw(RIGHT_SIDE_WIDTH,BOTTOM_Y,@tech_panel_back)
    Window.draw(RIGHT_SIDE_WIDTH+5,BOTTOM_Y+5,@game.selected_tech ? Image[@game.selected_tech] : Image[:science])
    Window.draw_font(RIGHT_SIDE_WIDTH+50,BOTTOM_Y+3,selected_tech_j,Font16)
    Window.draw_font(RIGHT_SIDE_WIDTH+50,BOTTOM_Y+21,make_research_str,Font16) 
    Window.draw(RIGHT_SIDE_WIDTH+5,BOTTOM_Y+52,@research_gage)

    if @game.selected_tech
      coin = @controller.pos_bottom == :tech_coin ? :coin_l : :coin
      Window.draw(RIGHT_SIDE_WIDTH+125,BOTTOM_Y+5,Image[coin])
    end

    #make_bottom_panel(160,70,:const_panel,@const_panel_back)
    Window.draw(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+10,BOTTOM_Y,@const_panel_back)
    Window.draw(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+15,BOTTOM_Y+5,Image[:production])
    Window.draw_font(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+60,BOTTOM_Y+3,selected_product_j,Font16)
    Window.draw_font(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+60,BOTTOM_Y+21,make_production_str,Font16)
    Window.draw(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+15,BOTTOM_Y+52,@production_gage)

    if @game.selected_product
      coin = @controller.pos_bottom == :product_coin ? :coin_l : :coin
      Window.draw(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+135,BOTTOM_Y+5,Image[coin])
    end

    Window.draw(5,BOTTOM_Y,Image[:writing])
  end

  def draw_rightside_info
    case(@controller.pos_rightside)
    when :deck
      Window.draw(Input.mouse_x,Input.mouse_y,@deckinfoback)
      @game.deck.sort{|a,b|a.name<=>b.name}.each_with_index do |c,i|
        Window.draw_font(Input.mouse_x+3,Input.mouse_y+3+18*i,c.name,Font16)
      end
    when :trash 
      Window.draw(Input.mouse_x,Input.mouse_y,@trashinfoback)
      @game.trash.sort{|a,b|a.name<=>b.name}.each_with_index do |c,i|
        Window.draw_font(Input.mouse_x+3,Input.mouse_y+3+18*i,c.name,Font16)
      end
    when :buildings
      Window.draw(Input.mouse_x,Input.mouse_y,@bldginfoback)
      array = @game.buildings+@game.wonders
      array.each_with_index do |e,i|
        Window.draw_font(Input.mouse_x+3,Input.mouse_y+3+18*i,@game.product_j(e),Font16)
      end      
    end
  end

  def draw_leftside_info
    case(@controller.pos_leftside)
    when :era_score
      Window.draw(Input.mouse_x-310,Input.mouse_y,@erainfoback)
      Window.draw_font(Input.mouse_x-307,Input.mouse_y+3,"【時代スコア獲得条件】",Font16)
      @game.era_missions.each_with_index do |str,i|
        Window.draw_font(Input.mouse_x-307,Input.mouse_y+3+18*(i+1),make_erainfo_str(str),Font16)
      end
      bonus = ERABONUS[@game.era]
      [bonus[0]-1,bonus[0],bonus[1]].each_with_index do |e,i|
        pri = "以下" if i == 0
        pri = "から#{bonus[1]-1}" if i == 1
        pri = "以上" if i == 2
        Window.draw_font(Input.mouse_x-307,Input.mouse_y+3+18*(i*2+5),e.to_s+pri,Font16)
        Window.draw_font(Input.mouse_x-300,Input.mouse_y+3+18*(i*2+6),make_erabonus_str(i),Font16)
      end
    end
  end

  def draw_log
    @game.log.each_with_index do |l,i|
      Window.draw_font(RIGHT_SIDE_WIDTH,BOTTOM_Y-18*i-20,l,Font16)
    end
  end

  def draw_tech_view
    @tech_array.reverse.each_with_index do |t,i|
      draw_tech_view_row(t,50+(i%2)*25,10+50*i)
    end
    # マウスオーバーで説明を表示
    pos_tech = @controller.pos_tech_view
    if pos_tech and pos_tech != :back
      @game.make_tech_text(@tech_array[pos_tech[0]][pos_tech[1]][0]).each_with_index do |t,i|
        Window.draw_font(50,330+18*i,t,Font16)
      end
    end

    if @game.click_mode == :select_tech_from_scientist
      Window.draw_font(RIGHT_SIDE_WIDTH+65,BOTTOM_Y+52,"研究済みの技術が1つ以上ある世代の技術を選んでください",Font16)
    else
      Window.draw(RIGHT_SIDE_WIDTH,BOTTOM_Y+50,@tech_view_back_button_back)
      Window.draw_font(RIGHT_SIDE_WIDTH+65,BOTTOM_Y+52,"戻る",Font16)
    end
    
  end

  def draw_tech_view_row(tech_array,x,y)
    tech_array.each_with_index do |t,i|
      Window.draw(x+i*50,y,@tech_back[t[0]])
      Window.draw(x+i*50+4,y+4,Image[t[0]])
    end
  end

  def draw_product_view
    Window.draw(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+10,BOTTOM_Y+50,@tech_view_back_button_back)
    Window.draw_font(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+75,BOTTOM_Y+52,"戻る",Font16)

    Window.draw_font(10, 10, "カード", Font20)
    Window.draw_font(130, 10, "建物", Font20)
    Window.draw_font(250, 10, "ユニット", Font20)
    Window.draw_font(370, 10, "世界遺産", Font20)

    @game.unlocked_products[:cards].each_with_index do |p,i|
      card = CARDDATA[p[0]]
      Window.draw_font(10, 35+18*i, card.name+p[1].to_s, Font16)
      Window.draw_font(100, 35+18*i, @game.product_cost(p), Font16)
    end
    @game.unlocked_products[:bldgs].each_with_index do |p,i|
      bldg = BLDGDATA[p]
      Window.draw_font(130, 35+18*i, bldg.name, Font16)
      Window.draw_font(220, 35+18*i, @game.product_cost(p), Font16)
    end
    @game.unlocked_products[:units].each_with_index do |p,i|
      unit = UNITDATA[p]
      color = C_WHITE
      color = DARKGRAY unless @game.product_selectable?([:units,i])
      Window.draw_font(250, 35+18*i, unit.name, Font16, {color: color})
      Window.draw_font(340, 35+18*i, @game.product_cost(p), Font16, {color: color})
    end
    @game.selectable_wonders.each_with_index do |p,i|
      wonder = WONDERSDATA[p]
      Window.draw_font(370, 35+18*i, wonder.name, Font16)
      Window.draw_font(555, 35+18*i, @game.product_cost(p), Font16)
    end

    # ユニット待機上限を表示
    Window.draw_font(50,400,"兵士ユニット #{@game.count_unit_at_utype(:soldier)}/#{@game.max_unit(:soldier)}",Font16)
    Window.draw_font(220,400,"騎乗ユニット #{@game.count_unit_at_utype(:mount)}/#{@game.max_unit(:mount)}",Font16)

    # マウスオーバーで説明を表示
    pos_product = @controller.pos_product_view
    if pos_product and pos_product != :back
      if pos_product[0] != :wonders
        @game.make_product_text(@game.unlocked_products[pos_product[0]][pos_product[1]]).each_with_index do |t,i|
          Window.draw_font(50,330+18*i,t,Font16)
        end
      else
        @game.make_product_text(@game.selectable_wonders[pos_product[1]]).each_with_index do |t,i|
          Window.draw_font(50,330+18*i,t,Font16)
        end
      end
    end
  end

  def draw_great_person_bonus
    case @game.selecting_great_person
    when :scientist
      texts = ["【ひらめき8】を#{@game.era+1}枚得る","技術1つを即座に研究完了する"]
    when :artist
      texts = ["【流行8】を#{@game.era+1}枚得る","《守護》を得る"]
    when :engineer
      texts = ["世界遺産を即座に生産する","《革新》を得る"]
    when :merchant
      texts = ["コインを#{((@game.era+1)*4)}枚得る","《投資》を得る"]
    end
    texts.each_with_index do |t,i|
      color = C_WHITE
      if @game.selecting_great_person == :scientist and i == 1 and !@game.can_select_scientist_bonus?
        color = DARKGRAY
      elsif @game.selecting_great_person == :engineer and i == 0 and @game.get_selectable_and_selected_wonders.size == 0
        color = DARKGRAY
      end
      Window.draw_font(RIGHT_SIDE_WIDTH,5+i*22,t,Font20,{color: color})
    end
  end

  def draw_log_view
    (@game.archive+@game.log).reverse.each_with_index do |text,i|
      Window.draw_font(10, 10+i*18, text, Font16)
    end
    Window.draw_font(300, 460, "クリックで戻ります", Font16)
  end

  def draw_message(str_array)
    str_array.each_with_index do |text, i|
      Window.draw_font(10, 480-MESSAGE_BOX_HEIGHT+i*22, text, Font20) 
    end
  end

  def selected_tech_j
    return "技術を選択" unless @game.selected_tech
    return @game.tech_j(@game.selected_tech)
  end

  def selected_product_j
    return "生産物を選択" unless @game.selected_product
    return @game.product_j(@game.selected_product)
  end

  def refresh_tech_view
    @flat_tech_array.map{|e|e[0]}.each do |t|
      @tech_back[t].box_fill(0,0,40,40,DARKGRAY)
      @tech_back[t].box_fill(0,0,40,40,DARKBLUE) if @game.tech_selectable?(t)
      @tech_back[t].box_fill(0,40-(@game.tech_prog[t]*40/@game.tech_cost(t)),40,40,C_GREEN)
    end
  end

  def refresh_product_view

  end

  def refresh_back
    @deckinfoback = Image.new(80,480)
    @trashinfoback = Image.new(80,480)
    @erainfoback = Image.new(310,480)
    @bldginfoback = Image.new(200,480)
    @deckinfoback.box_fill(0,0,80,@game.deck.size*18+6,DARKGRAY) if @game.deck.size > 0
    @trashinfoback.box_fill(0,0,80,@game.trash.size*18+6,DARKGRAY) if @game.trash.size > 0
    @erainfoback.box_fill(0,0,310,201,DARKGRAY)
    bnum = @game.buildings.size+@game.wonders.size
    @bldginfoback.box_fill(0,0,200,bnum*18+6,DARKGRAY) if bnum > 0
  end

  def refresh_gages
    @growth_gage = Image.new(100,10)
    @growth_gage.box_fill(0,0,@game.growth_pt*100/(@game.growth_level*4-2),10,C_GREEN)
    @great_person_gage = Image.new(100,10)
    @great_person_gage.box_fill(0,0,@game.great_person_pt*100/(@game.great_person_num*20+20),10,C_GREEN)

    tech = @game.selected_tech
    if tech
      @research_gage = Image.new(150,10)
      @research_gage.box_fill(0,0,@game.sum_research_pt*150/@game.tech_cost(tech),10,C_GREEN)
    end

    product = @game.selected_product
    if product
      @production_gage = Image.new(150,10)
      @production_gage.box_fill(0,0,@game.sum_product_pt*150/@game.product_cost(product),10,C_GREEN)
    end

  end

  def make_bottom_panel(width,height,sym,image)
    if @controller.pos_bottom == sym
      image.box_fill(0,0,width,height,DARKGRAY2)
    else
      image.box_fill(0,0,width,height,DARKGRAY)
    end
  end

  def make_research_str
    tech = @game.selected_tech
    return "" unless tech
    str = @game.sum_research_pt.to_s
    str += "/"+@game.tech_cost(tech).to_s
    return str
  end

  def make_production_str
    product = @game.selected_product
    return "" unless product
    str = (@game.sum_product_pt).to_s
    str += "/"+@game.product_cost(product).to_s
    return str
  end

  def make_bonus_str(pos)
    if @game.click_mode == :select_invasion_bonus
      ele = @game.invasion_bonus[0][pos].split(",")
      case(ele[0])
      when "get_province"
        return "属州を得る(#{ele[1]})"
      when "get_coin"
        return "コインを得る(#{ele[1]})"
      when "down_threat"
        return "脅威Lvを下げる(#{ele[1]})"
      end
    end
  end

  def make_erainfo_str(str)
    score = @game.get_era_score_from_str(str)
    case str
    when "research_tech"
      r = "世代#{@game.era+2}以上の技術を研究する"
    when "build_unit"
      r = "ユニットを生産する"
    when "build_card"
      r = "カードを生産する"
    when "build_bldg"
      r = "建物を建設する"
    when "success_invasion"
      r = "侵攻に成功する"
    when "success_defense"
      r = "防衛に成功する"  
    when "build_wonder"
      r = "世界遺産を建設する"
    when "growth_level_up"
      r = "成長Lvを上げる"
    when "born_great_person"
      r = "偉人を誕生させる"
    when "culture"
      r = "文化を#{@game.era*20+10}以上にする"
    end
    return r+": +#{score}"
  end

  def make_erabonus_str(i)
    array = ERABONUS[@game.era][i+2]
    str = ""
    array.each do |e|
      if e =~ /add_card\((.*)\)/
        card = $1.split(",")
        str += "カードを得る(#{CARDDATA[card[0].delete(":")].name}"
        str += card[1] if card[1] != "0"
        str += ") "
      elsif e =~ /add_coin\((\d*)\)/
        str += "#{$1}コインを得る "
      end
    end
    return str
  end

  def era_j
    return ["太古","古代","中世","ルネサンス","工業化時代","現代"][@game.era]
  end

  def draw_xy
    Window.draw_font(0,460,Input.mouse_pos_x.to_s+" "+Input.mouse_pos_y.to_s,Font16)
  end

  def draw_debug
  
  end

  def mouseover_color(bool, color=WHITE)
    return {color: GREEN} if bool
    return {color: color}
  end

end