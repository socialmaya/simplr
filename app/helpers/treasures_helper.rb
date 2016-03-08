module TreasuresHelper
  def kanye?
    if @treasure and @treasure.treasure_type.eql? 'kanye'
      true
    end
  end
  
  def treasure_type_options
    options = [['Type of treasure (node type)', nil]]
    Treasure.types.each do |key, val|
      options << [val, key.to_s]
    end
    return options
  end
  
  def power_options
    options = [['Power to unlock', nil], ['No power', 'no_power']]
    Treasure.powers.each do |key, val|
      options << [val, key.to_s]
    end
    return options
  end
end
