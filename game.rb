require_remote './card.rb'
require_remote './tech.rb'
require_remote './product.rb'
require_remote './click.rb'

class Game

include Tech
include Product
include Click

attr_accessor :status, :page, :view_status
attr_reader :game_status, :game_status_memo, :messages, :hand, :deck, :turn, :trash, :growth_level, :great_person_pt,
  :great_person_num, :growth_pt, :temp_research_pt, :culture_pt, :production_pt, :selected_tech, :selected_product,
  :era_score, :tech_prog, :tech_array, :flat_tech_array, :unlocked_products, :buildings, :units, :log, :archive, :coin, :coin_pt,
  :action_pt, :target, :click_mode, :threat, :invasion_bonus, :province

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
    @units = [:warrior]
    @invasion_bonus = BONUSDATA
    @coin = 0
    @threat = 1

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
    @culture_pt = 0
    @production_pt = 0
    @coin_pt = {science: 0, production: 0, growth: 0, culture: 0}
    @province = 0
    @province_pt = {science: 0, production: 0, growth: 1, culture: 0}

    @era_score = 0

    @log = []
    @archive = []

    calc_start_turn

    @page = 0
  end

  def start
    @status = :game
  end

  def turn_end
    calc_end_turn
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
    calc_end_turn_tech
    calc_end_turn_product
    calc_end_turn_growth
    calc_great_person
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

  def calc_great_person
    if @great_person_pt >= @great_person_num*20+20
      @great_person_pt -= @great_person_num*20+20
      @great_person_num += 1
    end
  end

  def calc_research
    @temp_research_pt = sum_point(:science)
  end

  def calc_culture
    @temp_culture_pt = sum_point(:culture)
  end

  def calc_production
    @production_pt = sum_point(:production)
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
    return array.inject{|sum,n|sum+n} + @coin_pt[kind] + get_province_pt(kind)
  end

  def add_log(str)
    @log.push str
  end

  def use_coin(sym)
    # TODO コインが0枚の時に使えないようにする　現在はテスト用に制限なく使える
    # 既に充分な研究・生産ポイントがある場合はコインは使えない
    case(sym)
    when :science
      return false if @tech_prog[@selected_tech]+@temp_research_pt+@coin_pt[sym] >= tech_cost(@selected_tech)
    when :production
      return false if get_product_prog(@selected_tech)+@production_pt+@coin_pt[sym] >= product_cost(@selected_product)
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

  def push_space

  end

  def get_province_pt(kind)
    return @privince * @province_pt[kind]
  end

  def get_att
    return @units.map{|u|UNITDATA[u].att}.inject{|sum,n|sum+n}
  end

  def get_def
    return @units.map{|u|UNITDATA[u].def}.inject{|sum,n|sum+n}
  end

  def init_deck
    array = []
    [[:authority,2],[:growth,2],[:trade,2],[:trade,2],[:production,1],[:inheritance,1],[:invasion,1]].each do |sym,n|
#    [[:science,1],[:science,1],[:growth,1],[:growth,1],[:growth,1],[:production,1],[:production,1]].each do |sym,n|
      array.push Card.new(sym,n)
    end
    return array
  end

end