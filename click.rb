module Click

# クリックで発生する処理をまとめるmodule

  def click_hand(pos)
    if @click_mode == :select_hand
      action_effect(pos)
      if @action_card[:n] == 0
        @click_mode = nil
        @action_card = nil
      end
      return
    end

    card = @hand[pos]
    return unless card.action?
    return if @action_pt == 0

    case card.kind
    when :authority
      @click_mode = :select_hand
      @action_card = {card: card, n: card.num}
      add_log("除外するカードを選んでください(#{card.num})")
    when :inheritance
      @click_mode = :select_hand
      @action_card = {card: card, n: card.num}
      add_log("次のターンに送るカードを選んでください(#{card.num})")
    when :invasion
      if get_att > @threat
        score_str = calc_era_mission("success_invasion")
        add_log("攻撃に成功！"+score_str)
        add_log("報酬を選んでください")
        @click_mode = :select_invasion_bonus
        @threat += 2
      else
        add_log("ユニットの攻撃力が脅威Lvより大きい必要があります")
        @action_pt += 1
      end
    when :trade
      cost = (card.num/2).floor
      if @coin >= cost
        draw_card(card.num)
        @coin -= cost
      else
        add_log("コインを#{cost}支払う必要があります")
        @action_pt += 1  
      end
    end
    @action_pt -= 1
    
  end

  def action_effect(pos)
    case @action_card[:card].kind 
    when :authority
      card = @hand[pos].name
      add_log("#{card}を除外しました")
      @hand.delete_at(pos)
      @action_card[:n] -= 1
    when :inheritance
      card = @hand[pos].name
      add_log("#{card}を次のターンに送りました")
      next_card = @hand.delete_at(pos)
      @inheritance.push next_card
      calc_all_points
      @action_card[:n] -= 1
    end
  end

  def click_bonus(pos)
  	return if @click_mode == :select_invasion_bonus and !@invasion_bonus[0][pos]
  	if @click_mode == :select_invasion_bonus
  	  bonus = @invasion_bonus[0][pos].split(",")
  	  num = bonus[1].to_i
  	  case(bonus[0])
  	  when "get_province"
  	  	@province += num
  	  	add_log("属州を得た")
  	  when "get_coin"
  	  	@coin += num
  	  	add_log("コインを得た(#{num})")
  	  when "down_threat"
  	  	@threat -= num
  	  	add_log("脅威Lvが下がった(#{num})")
  	  when "get_great_general"
  	  	add_log("大将軍が誕生！")
  	  end
  	  @invasion_bonus[0].delete_at(pos)
  	  @invasion_bonus.delete_at(0) if @invasion_bonus[0].size == 0
  	  @click_mode = nil
  	end
  end


end