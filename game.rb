require_remote './card.rb'
require_remote './tech.rb'

class Game

include Tech

attr_accessor :status, :page, :view_status
attr_reader :game_status, :game_status_memo, :messages, :hand, :deck, :turn, :trash, :growth_level, :great_person_pt,
  :great_person_num, :growth_pt, :temp_research_pt, :culture_pt, :production_pt, :selected_tech, :selected_product,
  :era_score, :tech_prog

  def initialize
    @status = :title
    @game_status = nil
    @game_status_memo = nil
    @view_status = :main_view
    @tech_array = [TECH_1,TECH_2,TECH_3,TECH_4,TECH_5,TECH_6]
    @tech_prog = {}
    (TECH_1+TECH_2+TECH_3+TECH_4+TECH_5+TECH_6).map{|e|e[0]}.each do |sym|
      @tech_prog[sym] = 0
    end

    @messages = [""]
    @turn = 1
    @deck = init_deck.shuffle
    @hand = [@deck.pop,@deck.pop,@deck.pop]
    @trash = []

    @selected_tech = nil
    @selected_product = nil

    @growth_level = 1
    @growth_pt = 0
    @great_person_num = 0    
    @great_person_pt = 0
    @temp_research_pt = 0
    @culture_pt = 0
    @production_pt = 0

    @era_score = 0

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
    (@growth_level+2).times do 
      @hand.push @deck.pop
      if @deck.size == 0
        @deck = @trash.shuffle
        @trash = []
      end
    end
    @turn += 1
    calc_start_turn

    #p "turn "+@turn.to_s
    #p @hand.map{|e|e.name},@deck.map{|e|e.name},@trash.map{|e|e.name}
  end

  def calc_start_turn
    calc_growth
    calc_great_person
    calc_research
    calc_culture
    calc_production
  end

  def calc_end_turn
    calc_end_turn_tech

  end

  def calc_growth
    pt = sum_point(:growth)
    if pt >= @growth_level*4-2
      @great_person_pt += pt - (@growth_level*4-2)
      pt -= (@growth_level*4-2)
      @growth_level += 1
      add_log("成長レベルが上がった！")
    else
      @great_person_pt += pt
    end
    @growth_pt = pt
  end

  def calc_great_person
    if @great_person_pt >= @great_person_num*20+20
      @great_person_pt -= @great_person_num*20+20
      @great_person_num += 1
    end
  end

  def calc_research
    @temp_research_pt += sum_point(:science)
  end

  def calc_culture
    @culture_pt += sum_point(:culture)
  end

  def calc_production
    @production_pt += sum_point(:production)
  end

  def selectable_turn_end?
    return false unless @selected_tech
    return true
  end

  def sum_point(kind)
    array = @hand.select{|e|e.kind == kind}.map{|e|e.num}
    return 0 if array.size == 0
    return array.inject{|sum,n|sum+n}
  end

  def add_log(str)
    p str
  end

  def push_space

  end

  def init_deck
    array = []
    [[:science,1],[:science,1],[:growth,1],[:growth,1],[:growth,1],[:production,1],[:production,1]].each do |sym,n|
      array.push Card.new(sym,n)
    end
    return array
  end

end