require_remote './card.rb'

class Game

attr_accessor :status, :page
attr_reader :game_status, :game_status_memo, :messages, :hand, :deck, :turn, :trash, :growth_level, :great_person_pt,
  :great_person_num, :growth_pt, :research_pt, :culture_pt, :production_pt, :selected_tech, :selected_product

  def initialize
    @status = :title
    @game_status = nil
    @game_status_memo = nil

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
    @research_pt = 0
    @culture_pt = 0
    @production_pt = 0

    calc_turn

    @page = 0
  end

  def start
    @status = :game
  end

  def turn_end
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
    calc_turn

    #p "turn "+@turn.to_s
    #p @hand.map{|e|e.name},@deck.map{|e|e.name},@trash.map{|e|e.name}
  end

  def calc_turn
    calc_growth
    calc_great_person
    calc_research
    calc_culture
    calc_production
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
    @research_pt += sum_point(:science)
  end

  def calc_culture
    @culture_pt += sum_point(:culture)
  end

  def calc_production
    @production_pt += sum_point(:production)
  end

  def sum_point(kind)
    array = @hand.select{|e|e.kind == kind}.map{|e|e.num}
    return 0 if array.size == 0
    return array.inject{|sum,n|sum+n}
  end

  def add_log(str)
    p str
  end

  def init_deck
    array = []
    [[:science,1],[:science,1],[:growth,1],[:growth,1],[:growth,1],[:production,1],[:production,1],[:culture,1]].each do |sym,n|
      array.push Card.new(sym,n)
    end
    return array
  end

end