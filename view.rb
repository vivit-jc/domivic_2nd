class View

  def initialize(game,controller)
    @game = game
    @controller = controller

    @cardback = Image.new(60,60)
    @cardback.box_fill(0,0,60,60,DARKGRAY)
    @unitback = Image.new(60,60)
    @unitback.box_fill(0,0,60,60,DARKRED)
    @buttonback = Image.new(170,70)
    @buttonback.box_fill(0,0,170,70,YELLOW)
    @bottom_panel_back = Image.new(160,70)
    @bottom_panel_back.box_fill(0,0,160,70,DARKGRAY)

    @growth_gage = Image.new(100,10)
    @great_person_gage = Image.new(100,10)
    @research_gage = Image.new(140,10)
    @production_gage = Image.new(140,10)
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
    end
    draw_hand
    draw_rightside
    draw_leftside
    draw_units
    draw_bottom
    draw_message(@game.messages)
    case @game.game_status
    when :main
      p "test"
    end

  end

  def draw_hand

    @game.hand.each_with_index do |card,i|
      x = RIGHT_SIDE_WIDTH+(i%5)*65
      y = 5+65*(i/5).floor
      Window.draw(x,y,@cardback)
      Window.draw(x+2,y+2,Image[card.kind])
      Window.draw_font(x+2,y+38,card.name,Font16)
    end
    
  end

  def draw_units
    array = [
      [:sword,"3/1"],
      [:arch,"1/3"],
      [:arch,"1/3"]
    ]
    array.each_with_index do |img,i|
      x = RIGHT_SIDE_WIDTH+(i%5)*65
      y = UNITS_Y+65*(i/5).floor
      Window.draw(x,y,@unitback)
      Window.draw(x+2,y+2,Image[img[0]])
      Window.draw_font(x+2,y+38,img[1],Font16)
    end
  end

  def draw_rightside

    Window.draw(5,5,Image[:deck])
    Window.draw(44,5,Image[:trash])
    Window.draw_font(8,42,sprintf("% 2d",@game.deck.size),Font20)
    Window.draw_font(47,42,sprintf("% 2d",@game.trash.size),Font20)
    Window.draw(5,62,Image[:growth])
    Window.draw_font(45,65,"Lv#{@game.growth_level}",Font16)
    Window.draw_font(45,83,"#{@game.growth_pt}/#{@game.growth_level*4-2}",Font16)
    Window.draw(5,100,@growth_gage)
    Window.draw(5,115,Image[:greatperson])
    Window.draw_font(45,135,"#{@game.great_person_pt}/#{@game.great_person_num*20+20}",Font16)
    Window.draw(5,153,@great_person_gage)

    Window.draw_font(5,170,"属州 2",Font20)
    Window.draw_font(5,190,"脅威Lv 2",Font20)
    Window.draw_font(5,210,"建築物 3",Font20)

    Window.draw(5,240,Image[:emblem])
    Window.draw(42,240,Image[:culture])
    Window.draw_font(8,280,"02",Font20)
    Window.draw_font(44,280,sprintf("% 2d",@game.culture_pt.to_s),Font20)
    
  end

  def draw_leftside
    Window.draw_font(LEFT_SIDE_X+20,5,"【太古】",Font28)
    Window.draw_font(LEFT_SIDE_X,40,"ターン #{@game.turn}/10",Font20)
    Window.draw_font(LEFT_SIDE_X,60,"時代スコア 4",Font20)
    Window.draw(LEFT_SIDE_X,BOTTOM_Y,@buttonback)
    Window.draw_font(LEFT_SIDE_X+14,BOTTOM_Y+23,"ターン終了",Font28,{color: C_BLACK})

  end

  def draw_bottom
    Window.draw(RIGHT_SIDE_WIDTH,BOTTOM_Y,@bottom_panel_back)
    Window.draw(RIGHT_SIDE_WIDTH+5,BOTTOM_Y+5,Image[:science])
    Window.draw_font(RIGHT_SIDE_WIDTH+50,BOTTOM_Y+3,selected_tech_j,Font16)
    Window.draw_font(RIGHT_SIDE_WIDTH+50,BOTTOM_Y+21,"#{@game.research_pt}/15",Font16)
    Window.draw(RIGHT_SIDE_WIDTH+5,BOTTOM_Y+52,@research_gage)
    
    Window.draw(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+10,BOTTOM_Y,@bottom_panel_back)
    Window.draw(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+15,BOTTOM_Y+5,Image[:production])
    Window.draw_font(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+60,BOTTOM_Y+3,selected_product_j,Font16)
    Window.draw_font(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+60,BOTTOM_Y+21,"#{@game.production_pt}/20",Font16)
    Window.draw(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+15,BOTTOM_Y+52,@production_gage)
  end


  def draw_message(str_array)
    str_array.each_with_index do |text, i|
      Window.draw_font(10, 480-MESSAGE_BOX_HEIGHT+i*22, text, Font20) 
    end
  end

  def selected_tech_j
    return "技術を選択" unless @game.selected_tech
    tech_list = TECH_1+TECH_2+TECH_3+TECH_4+TECH_5+TECH_6
    return tech_list.find{|e|e[0] == @game.selected_tech}[1]
  end

  def selected_product_j
    return "生産物を選択"
  end

  def refresh_gages
    @growth_gage.box_fill(0,0,100,10,C_BLACK)
    @growth_gage.box_fill(0,0,@game.growth_pt*100/(@game.growth_level*4-2),10,C_GREEN)
    @great_person_gage.box_fill(0,0,100,10,C_BLACK)
    @great_person_gage.box_fill(0,0,@game.great_person_pt*100/(@game.great_person_num*20+20),10,C_GREEN)
    @research_gage.clear
    @production_gage.clear

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