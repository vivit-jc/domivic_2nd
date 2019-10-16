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
    @game.turn_end if pos_leftside == :turn_end
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
      d_height += height
      return sym if(mcheck(RIGHT_SIDE_WIDTH, BOTTOM_Y, RIGHT_SIDE_WIDTH+d_width, BOTTOM_Y+d_height))
      d_width += 10
      d_height += 10
    end
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