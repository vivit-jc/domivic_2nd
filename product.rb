module Product

  def refresh_unlocked_products
  	@unlocked_products = {tiles: [], bldgs: [], units: []}
    @flat_tech_array.each do |tech,j|
      if tech_finished?(tech)
      	tiles = DATA[tech][:unlock_tile]
      	bldgs = DATA[tech][:unlock_bldg]
      	units = DATA[tech][:unlock_unit]
      	
      	@unlocked_products[:tiles] += tiles if tiles
      	@unlocked_products[:bldgs] += bldgs if bldgs
      	@unlocked_products[:units] += units if units  	
      end
    end
  end

  def calc_end_turn_product
  	refresh_unlocked_products
  end

end