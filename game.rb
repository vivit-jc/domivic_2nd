require_remote './card.rb'

class Game

attr_accessor :status, :page
attr_reader :game_status, :game_status_memo, :messages, :hand, :deck, :turn, :trash

  def initialize
    @status = :title
    @game_status = nil
    @game_status_memo = nil

    @messages = [""]
    @turn = 1
    @deck = init_deck.shuffle
    @hand = [@deck.pop,@deck.pop,@deck.pop]
    @trash = []

    @growth_level = 1

    @page = 0
  end

  def start
    @status = :game
  end

  def turn_end
    while(@hand.size > 0)
      @trash.push @hand.pop
    end
    3.times do 
      @hand.push @deck.pop
      if @deck.size == 0
        @deck = @trash.shuffle
        @trash = []
      end
    end
    check_growth
    #p "turn "+@turn.to_s
    #p @hand.map{|e|e.name},@deck.map{|e|e.name},@trash.map{|e|e.name}
  end

  def check_growth
    sum_point(:growth)
  end

  def sum_point(kind)
    
  end

  def init_deck
    array = []
    [[:science,1],[:science,1],[:growth,1],[:growth,1],[:growth,1],[:production,1],[:production,1],[:culture,1]].each do |sym,n|
      array.push Card.new(sym,n)
    end
    return array
  end

end