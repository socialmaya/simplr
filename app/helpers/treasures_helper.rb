module TreasuresHelper
  def random_treasure
    Treasure.find_by_id(rand 1..Treasure.all.size)
  end
end
