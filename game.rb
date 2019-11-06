require_remote './card.rb'
require_remote './unit.rb'
require_remote './tech.rb'
require_remote './product.rb'
require_remote './click.rb'

class Game

include Tech
include Product
include Click

attr_accessor :status, :page, :view_status
attr_reader :game_status, :game_status_memo, :messages, :hand, :deck, :turn, :trash, :growth_level, :great_person_pt,
  :great_person_num, :growth_pt, :temp_research_pt, :over_research_pt, :culture_pt, :temp_culture_pt, :temp_product_pt, :over_product_pt, 
  :selected_tech, :selected_product,
  :era, :era_score, :tech_prog, :tech_array, :flat_tech_array, :unlocked_products, 
  :buildings, :wonders, :units, :log, :archive, :coin, :coin_pt,
  :action_pt, :target, :click_mode, :threat, :invasion_bonus, :province, :selectable_wonders, :era_missions

  def initialize
    @status = :title
    @game_status = nil
    @game_status_memo = nil
    @view_status = :main_view
    @tech_array = [TECH_1,TECH_2,TECH_3,TECH_4,TECH_5,TECH_6]
    @flat_tech_array = TECH_1+TECH_2+TECH_3+TECH_4+TECH_5+TECH_6
    @tech_prog = {}
    @product_prog = {}
    @flat_tech_array.map{|e|e[0]}.each do |sym|
      @tech_prog[sym] = 0
    end
    @unlocked_products = {cards: [[:growth,1]], bldgs: [], units: [:warrior]}

    @messages = [""]
    @turn = 1
    @deck = init_deck.shuffle
    @hand = [@deck.pop,@deck.pop,@deck.pop]
    @trash = []
    @inheritance = []
    @buildings = []
    @wonders = []
    @units = [Unit.new(:warrior)]
    @invasion_bonus = BONUSDATA
    @coin = 100
    @threat = 1
    @defense_event = 0

    @selected_tech = nil
    @selected_product = nil
    @target = nil
    @click_mode = nil

    @action_pt = 0
    @growth_level = 1
    @growth_pt = 0
    @great_person_num = 0    
    @great_person_pt = 0

    @temp_research_pt = 0
    @over_research_pt = 0

    @temp_product_pt = 0
    @over_product_pt = 0

    @culture_pt = 0
    @temp_culture_pt = 0

    @coin_pt = {science: 0, production: 0, growth: 0, culture: 0}
    @province = 0
    @province_pt = {science: 0, production: 0, growth: 1, culture: 0}

    @era = 0
    @era_score = 0
    @era_missions = []
    @era_culture_flag = Array.new(6,false)
    
    @log = []
    @archive = []

    set_wonders
    set_era_missions
    calc_start_turn

    @page = 0
  end

  def start
    @status = :game
  end

  def click_turn_end
    return unless selectable_turn_end?
    if @hand.select{|c|c.kind == :threat}.size > @defense_event 
      calc_defense_event
    else
      turn_end
    end
  end

  def turn_end
    calc_end_turn
    @hand = @hand.select{|c|!c.instant?}
    while(@hand.size > 0)
      @trash.push @hand.pop
    end
    # 山札の枚数が成長レベル+2より少ない場合は全部引く
    draw_card([@trash.size+@deck.size,@growth_level+2].min)
    @hand += @inheritance
    @inheritance = []

    @turn += 1
    calc_start_turn

    #p "turn "+@turn.to_s
    #p @hand.map{|e|e.name},@deck.map{|e|e.name},@trash.map{|e|e.name}
  end

  def calc_start_turn
    @action_pt = 1
    calc_all_points
  end

  def calc_end_turn
    @archive += @log
    @log = []
    @culture_pt += @temp_culture_pt
    @defense_event = 0
    calc_end_turn_tech
    calc_end_turn_product
    calc_end_turn_growth
    calc_great_person
    calc_era_mission("culture")
    go_next_era
  end

  def calc_growth
    @growth_pt = sum_point(:growth)
  end

  def calc_end_turn_growth
    if @growth_pt >= @growth_level*4-2
      @great_person_pt += @growth_pt - (@growth_level*4-2)
      @growth_level += 1
      add_log("成長レベルが上がった！")
    else
      @great_person_pt += @growth_pt
    end
    @growth_pt = 0

  end

  def calc_defense_event
    if get_def >= @threat
      add_log("防衛成功! "+calc_era_mission("success_defense"))
    else
      add_log("防衛に失敗・・・")
      calc_penalty
    end
    @threat += 1
    @defense_event += 1
  end

  def calc_penalty
    penalty = [:bldg,:unit,:stagnation,:riot,:research,:great_person,:growth_lv].sample
    case penalty 
    when :bldg
      # 建物をランダムにN/3(切り上げ)個失う。建物が無い場合は選ばれない。
      if @buildings.size == 0
        calc_penalty
        return
      end
      targets = []
      tarray = @buildings.shuffle
      ((@era/4).floor+1).times do
        break if tarray.size == 0
        t = tarray.pop
        add_log(BLDGDATA[t].name+"が破壊された")
        @buildings.delete(t)
        @product_prog[t] = 0
      end
    when :unit
      # ユニットをランダムに1~N個失う。ユニットが無い場合は選ばれない。
      if @units.size == 0
        calc_penalty
        return
      end
      targets = []
      tarray = @units.shuffle
      (rand(@era+1)+1).times do
        break if tarray.size == 0
        t = tarray.pop
        add_log(t.name+"が破壊された")
        @units.delete(t)
      end
    when :stagnation
      array = []
      (@era+1).times{array.push Card.new(:stagnation,0)}
      @trash += array
      add_log("【停滞】を#{@era+1}枚得た")
    when :riot
      array = []
      ((@era+1)*2).times{array.push Card.new(:riot,0)}
      @trash += array
      add_log("【動乱】を#{(@era+1)*2}枚得た")
    when :research
      # 現在研究中の技術の進捗が失われる。進捗が半分以下の場合は選ばれない
      if @tech_prog[@selected_tech] <= tech_cost(@selected_tech)/2
        calc_penalty
        return
      end
      @tech_prog[@selected_tech] = 0
      add_log("#{tech_j(@selected_tech)}の研究がすべて失われた")
    when :great_person
      if @great_person_pt < @great_person_num*10+10
        calc_penalty
        return
      end      
      @great_person_pt /= 2
      @great_person_pt = @great_person_pt.floor
      add_log("偉人ポイントが半分に減った")
    when :growth_lv
      if @growth_level == 1
        calc_penalty
        return
      end
      @growth_level -= 1
      add_log("成長Lvが1下がった")
    end
  end

  def calc_great_person
    if @great_person_pt >= @great_person_num*20+20
      @great_person_pt -= @great_person_num*20+20
      @great_person_num += 1
    end
  end

  def calc_research
    @temp_research_pt = sum_point(:science) + sum_point(:inspiration)
  end

  def calc_culture
    @temp_culture_pt = sum_point(:culture) + sum_point(:trend)
  end

  def calc_production
    @temp_product_pt = sum_point(:production)
  end

  def selectable_turn_end?
    return false unless @selected_tech
    return false unless @selected_product
    return true
  end

  def need_to_turn_end_mes
    if !@selected_tech
      return "技術が未選択です"
    elsif !@selected_product
      return "生産対象が未選択です"
    end
  end

  def sum_point(kind)
    array = @hand.select{|e|e.kind == kind}.map{|e|e.num}
    return 0 if array.size == 0
    return array.inject{|sum,n|sum+n} if CARDDATA[kind].instant
    return array.inject{|sum,n|sum+n} + @coin_pt[kind] + get_province_pt(kind)
  end

  def add_log(str)
    @log.push str
  end

  def use_coin(sym)
    return false if @coin == 0

    # 既に充分な研究・生産ポイントがある場合はコインは使えない
    case(sym)
    when :science
      return false if sum_research_pt >= tech_cost(@selected_tech)
    when :production
      return false if sum_product_pt >= product_cost(@selected_product)
    end
    @coin_pt[sym] += 1
    @coin -= 1
  end

  def draw_card(num)
    num.times do 
      if @deck.size == 0
        @deck = @trash.shuffle
        @trash = []
        return if @deck.size == 0
      end
      @hand.push @deck.pop
    end
    calc_all_points
  end

  def calc_all_points
    calc_growth
    calc_research
    calc_culture
    calc_production
  end

  def go_next_era
    return unless @turn == (@era+1)*TURN_ERA
    add_log("次の時代になった")
    give_era_reward
    set_era_missions
    add_card(:threat,0)
    @era += 1
    set_wonders
  end

  def push_space

  end

  def get_province_pt(kind)
    return @province * @province_pt[kind]
  end

  def get_att
    return 0 if @units.size == 0
    return @units.map{|u|u.att}.inject{|sum,n|sum+n}
  end

  def get_def
    return 0 if @units.size == 0
    return @units.map{|u|u.def}.inject{|sum,n|sum+n}
  end

  def give_era_reward
    if @era_score < ERABONUS[@era][0]
      ERABONUS[@era][2].each{|e|eval(e)}
    elsif @era_score < ERABONUS[@era][1]
      ERABONUS[@era][3].each{|e|eval(e)}
    else
      ERABONUS[@era][4].each{|e|eval(e)}
    end
  end

  def set_era_missions
    @era_score = 0
    @era_missions = []
    pt = [0,1,2]
    pt.delete_at(rand(2))
    2.times do |i|
      missions = ERAMISSION[pt[i]]
      ["success_defense","success_invasion","growth_level_up","born_great_person"].each do |e|
        missions.delete(e) if @era == 0
      end
      @era_missions.push missions.sample
    end
    @era_missions.push "culture"
  end

  def calc_era_mission(str)
    return "" unless @era_missions.include?(str)
    score = get_era_score_from_str(str)
    return "" if str == "research_tech" and tech_era(@selected_tech) <= @era
    return "" if str == "culture" and (@culture_pt < @era*20+10 or @era_culture_flag[@era])
    @era_score += score
    if str == "culture"
      add_log("文化が#{@era*20+10}以上になった 時代スコア+#{score}")
      @era_culture_flag[@era] = true
    end
    return " 時代スコア +#{score}"
  end

  # この時代の時代ミッションに設定されているかどうかは関係なくスコアを返す
  def get_era_score_from_str(str)
    return 2 if str == "culture"
    ERAMISSION.each_with_index do |e,i|
      return i+1 if e.include?(str)
    end
  end

  def set_wonders
    @selectable_wonders = WONDERSLIST[@era].shuffle
  end

  def exist_defense_event?
    return @hand.select{|c|c.kind == :threat}.size > @defense_event 
  end

  def add_card(kind,num)
    card = Card.new(kind,num)
    @trash.push card
    add_log("【#{card.name}】を得た")
  end

  def add_coin(n)
    @coin += n
    add_log("#{n}コインを得た")
  end

  def init_deck
    array = []
    [[:authority,2],[:growth,2],[:inspiration,8],[:trade,2],[:threat,0],[:production,5],[:riot,1],[:trend,5]].each do |sym,n|
#    [[:science,1],[:science,1],[:growth,1],[:growth,1],[:growth,1],[:production,1],[:production,1]].each do |sym,n|
      array.push Card.new(sym,n)
    end
    return array
  end

end