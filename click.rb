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
      card = @hand[pos]
      if card.kind == :threat
        add_log("【脅威】は選べません")
        return
      end
      add_log("#{card.name}を除外した")
      @hand.delete_at(pos)
      @action_card[:n] -= 1
    when :inheritance
      card = @hand[pos].name
      add_log("#{card}を次のターンに送った")
      next_card = @hand.delete_at(pos)
      @inheritance.push next_card
      calc_all_points
      @action_card[:n] -= 1
    end
  end

  def click_bonus(pos)
  	return if @click_mode == :select_invasion_bonus and !@invasion_bonus[0][pos]
  	case @click_mode
    when :select_invasion_bonus
      select_invasion_bonus(pos)
    when :select_great_person_bonus
      select_great_person_bonus(pos)
    when :select_wonder_from_engineer
      select_wonder_from_engineer(pos)
    end
  end

  def select_invasion_bonus(pos)
    bonus = @invasion_bonus[0][pos].split(",")
    num = bonus[1].to_i
    case(bonus[0])
    when "get_province"
      @province += num
      add_log("属州を得た")
    when "get_coin"
      add_coin(num)
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

  def select_great_person_bonus(pos)
    return false if pos >= 2
    case @selecting_great_person
    when :scientist
      if pos == 0
        (@era+1).times{@trash.push Card.new(:inspiration,8)}
        add_log("【ひらめき8】を#{@era+1}枚得た")
      else
        if can_select_scientist_bonus?
          @click_mode = :select_tech_from_scientist
          @view_status = :tech_view
        else
          add_log("研究できる技術がありません")
        end
        return # @click_modeがnilになってはまずいのでreturnする
      end
    when :artist
      if pos == 0
        (@era+1).times{@trash.push Card.new(:trend,8)}
        add_log("【流行8】を#{@era+1}枚得た")
      else
        @emblems.push :guardian
        add_log("《守護》を得た")
      end         
    when :engineer
      if pos == 0
        if @selectable_wonders.size == 0 and !WONDERSDATA[@selected_product]
          add_log("建設できる世界遺産がありません")
        else
          add_log("建設する世界遺産を選択してください")
          @click_mode = :select_wonder_from_engineer
        end
        return # @click_modeがnilになってはまずいのでreturnする
      else
        @emblems.push :innovation
        add_log("《革新》を得た")
      end
    when :merchant
      if pos == 0
        add_coin((@era+1)*4)
      else
        @emblems.push :investment
        add_log("《投資》を得た")
      end
    end
    @click_mode = nil
  end

  def select_wonder_from_engineer(pos)
    wonders = get_selectable_and_selected_wonders
    return if pos >= wonders.size
    @wonders.push wonders[pos]
    add_log("生産完了: "+product_j(wonders[pos])+calc_era_mission("build_wonder"))
    @click_mode = nil
  end

end