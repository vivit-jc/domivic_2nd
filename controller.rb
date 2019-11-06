require 'native' 
#alias_method :new_name, :old_name

class Controller
  attr_reader :x,:y,:mx,:my

  def initialize(game)
    @game = game
  end

  def input
    @mx = Input.mouse_x
    @my = Input.mouse_y
    if Input.mouse_push?( M_LBUTTON )
      case @game.status
      when :title
        @game.start if(pos_title_menu == 0)
        #@game.stats if(pos_title_menu == 1)
        #@game.all_clear if(pos_title_menu == 2)
      when :game
        click_on_game
      when :stats
        @game.go_title if(pos_return)
      when :end
        @game.next if(pos_return)
      end
    end
    if(Input.key_push?(K_SPACE))
      case @game.status
      when :game
        @game.push_space
      end
    end
  end

  def click_on_game

    if @game.click_mode
      if @game.click_mode == :select_invasion_bonus
        @game.click_bonus(pos_bonus) if pos_bonus
        return
      end
    else
      @game.click_turn_end if pos_leftside == :turn_end
    end

    @game.click_hand(pos_hand) if pos_hand and @game.view_status == :main_view

    # 技術選択画面か生産選択画面に行く、研究・生産へのコインの使用
    if @game.view_status == :main_view
      case(pos_bottom)
      when :tech_panel
        @game.view_status = :tech_view
        return
      when :const_panel
        @game.view_status = :product_view
        return
      when :tech_coin
        if @game.selected_tech
          @game.use_coin(:science) 
        else
          @game.view_status = :tech_view
        end
        return
      when :product_coin
        if @game.selected_product
          @game.use_coin(:production)
        else
          @game.view_status = :product_view
        end
      when :log
        @game.view_status = :log_view
        return        
      end
    end

    # 技術選択画面で技術か戻るボタンをクリックしたとき
    if @game.view_status == :tech_view and pos_tech_view
      if pos_tech_view == :back
        @game.view_status = :main_view
        return
      end
      # 既に完了している技術は選べない
      return false if @game.tech_finished?(@game.get_tech_sym_from_xy(pos_tech_view))
      # まだ研究できない技術は選べない
      return false unless @game.tech_selectable?(@game.get_tech_sym_from_xy(pos_tech_view))
      @game.set_researching_tech(@game.get_tech_sym_from_xy(pos_tech_view))
      @game.view_status = :main_view
    end

    # 生産選択画面で生産物か戻るボタンをクリックしたとき
    if @game.view_status == :product_view and pos_product_view
      if pos_product_view == :back
        @game.view_status = :main_view
        return
      end
      @game.set_producing_obj(pos_product_view)
      @game.view_status = :main_view
    end

    @game.view_status = :main_view if @game.view_status == :log_view 

  end

  def pos_title_menu
    3.times do |i|
      #return i if(mcheck(MENU_X, MENU_Y[i], MENU_X+Font32.get_width(MENU_TEXT[i]), MENU_Y[i]+32))
      return i if(mcheck(TITLE_MENU_X, TITLE_MENU_Y[i], TITLE_MENU_X+get_width(TITLE_MENU_TEXT[i]), TITLE_MENU_Y[i]+32))
    end
    return -1
  end

  def pos_hand
    @game.hand.each_with_index do |card,i|
      x = RIGHT_SIDE_WIDTH+(i%5)*65
      y = 5+65*(i/5).floor
      return i if mcheck(x,y,x+60,y+60)
    end
    return false
  end

  def pos_unit
    @game.units.each_with_index do |unit,i|
      x = RIGHT_SIDE_WIDTH+(i%5)*65
      y = UNITS_Y+65*(i/5).floor
      return i if mcheck(x,y,x+60,y+60)
    end
    return false
  end

  def pos_bonus
    6.times do |i|
      return i if mcheck(RIGHT_SIDE_WIDTH,5+i*22,440,5+i*22+20)
    end
    return false
  end

  def pos_rightside
    return :deck if mcheck(5,5,37,37)
    return :trash if mcheck(44,5,76,37)
    return :buildings if mcheck(5,170,45,210)
  end

  def pos_leftside
    d_width = 0
    d_height = 0
    return :era_score if mcheck(LEFT_SIDE_X,5,640,82)
    [[170,70,:turn_end]].each do |width, height, sym|
      d_width += width
      d_height += height
      return sym if(mcheck(LEFT_SIDE_X, BOTTOM_Y, LEFT_SIDE_X+d_width, BOTTOM_Y+d_height))
    end
    return -1
  end

  def pos_bottom
    d_width = 0
    d_height = 0
    return :tech_coin if mcheck(RIGHT_SIDE_WIDTH+125, BOTTOM_Y+5, RIGHT_SIDE_WIDTH+125+32, BOTTOM_Y+5+32)
    return :product_coin if mcheck(RIGHT_SIDE_WIDTH+170+125, BOTTOM_Y+5, RIGHT_SIDE_WIDTH+170+125+32, BOTTOM_Y+5+32)  
    [[160,70,:tech_panel],[160,70,:const_panel]].each do |width, height, sym|
      d_width += width
      return sym if(mcheck(RIGHT_SIDE_WIDTH, BOTTOM_Y, RIGHT_SIDE_WIDTH+d_width, BOTTOM_Y+height))
      d_width += 10
    end

    return :log if mcheck(5,BOTTOM_Y,5+32,BOTTOM_Y+32)
    return false
  end

  # return [時代0~5, 左から何番目か]
  def pos_tech_view
    [TECH_6,TECH_5,TECH_4,TECH_3,TECH_2,TECH_1].each_with_index do |t,row|
      t.size.times do |col|
        return [5-row,col] if mcheck(50+(row%2)*25+col*50,10+50*row,90+(row%2)*25+col*50,50+50*row)
      end
    end
    return :back if mcheck(RIGHT_SIDE_WIDTH,BOTTOM_Y+50,RIGHT_SIDE_WIDTH+BOTTOM_WIDTH,BOTTOM_Y+70)
    return false
  end

  # return [:cards/:units/:bldgs, 上から何番目か]
  def pos_product_view
    obj = @game.unlocked_products
    card = obj[:cards]
    bldg = obj[:bldgs]
    unit = obj[:units]
    wonders = @game.selectable_wonders

    card.each_with_index do |c,i|
      return [:cards,i] if mcheck(10,35+18*i,120,51+18*i)
    end

    bldg.each_with_index do |b,i|
      return [:bldgs,i] if mcheck(130,35+18*i,240,51+18*i)
    end

    unit.each_with_index do |u,i|
      return [:units,i] if mcheck(250,35+18*i,360,51+18*i)
    end

    wonders.each_with_index do |u,i|
      return [:wonders,i] if mcheck(370,35+18*i,580,51+18*i)
    end

    return :back if mcheck(RIGHT_SIDE_WIDTH+BOTTOM_WIDTH+10,BOTTOM_Y+50,RIGHT_SIDE_WIDTH+BOTTOM_WIDTH*2+10,BOTTOM_Y+70)
    return false
  end

  def get_width(str)
    canvas = Native(`document.getElementById('dxopal-canvas')`)
    width = canvas.getContext('2d').measureText(str).width
    return width
  end

  def mcheck(x1,y1,x2,y2)
    x1 < @mx && x2 > @mx && y1 < @my && y2 > @my    
  end

end