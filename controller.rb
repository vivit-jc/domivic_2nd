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
        @game.stats if(pos_title_menu == 1)
        @game.all_clear if(pos_title_menu == 2)
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
    @game.turn_end if @game.selectable_turn_end? and pos_leftside == :turn_end

    
    if @game.view_status == :main_view and pos_bottom == :tech_panel
      @game.view_status = :tech_view
      return
    end

    # 技術選択画面で技術をクリックしたとき
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
  end

  def pos_title_menu
    3.times do |i|
      #return i if(mcheck(MENU_X, MENU_Y[i], MENU_X+Font32.get_width(MENU_TEXT[i]), MENU_Y[i]+32))
      return i if(mcheck(TITLE_MENU_X, TITLE_MENU_Y[i], TITLE_MENU_X+get_width(TITLE_MENU_TEXT[i]), TITLE_MENU_Y[i]+32))
    end
    return -1
  end

  def pos_leftside
    d_width = 0
    d_height = 0
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
    [[160,70,:tech_panel],[160,70,:const_panel]].each do |width, height, sym|
      d_width += width
      return sym if(mcheck(RIGHT_SIDE_WIDTH, BOTTOM_Y, RIGHT_SIDE_WIDTH+d_width, BOTTOM_Y+height))
      d_width += 10
    end
    return false
  end

  # return [時代0~5, 左から何番目か]
  def pos_tech_view
    [TECH_6,TECH_5,TECH_4,TECH_3,TECH_2,TECH_1].each_with_index do |t,row|
      t.size.times do |col|
        return [5-row,col] if mcheck(50+(row%2)*20+col*50,10+50*row,90+(row%2)*20+col*50,50+50*row)
      end
    end
    return :back if mcheck(RIGHT_SIDE_WIDTH,BOTTOM_Y+50,RIGHT_SIDE_WIDTH+160,BOTTOM_Y+70)
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