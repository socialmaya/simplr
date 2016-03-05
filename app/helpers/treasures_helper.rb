module TreasuresHelper
  def looted? treasure
    true if current_user.treasures.find_by_name treasure.name
  end
  
  def power_options
    options = [['Power to unlock', nil], ['No power', 'no_power']]
    Treasure.powers.each do |key, val|
      options << [val, key.to_s]
    end
    return options
  end
  
  def random_treasure
    _treasure = nil
    treasures = Treasure.where(treasure_id: nil)
    if treasures.present?
      rand_num = rand 0..treasures.size-1
      i=0; for treasure in treasures
        if i.eql? rand_num
          _treasure = treasure
          break
        end
        i+=1
      end
    else
      _treasure = Treasure.create
    end
    return _treasure
  end
end
