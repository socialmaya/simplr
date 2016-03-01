class TreasuresController < ApplicationController
  def loot
    @treasure = Treasure.find_by_unique_token(params[:token])
    @treasure = current_user.loot @treasure
  end
  
  def create
    @treasure = Treasure.new(treasure_params)
    if @treasure.save
      redirect_to show_treasure_path @treasure.unique_token
    else
      redirect_to :back
    end
  end
  
  def update
  end
  
  def show
    @treasure = Treasure.find_by_unique_token(params[:token])
  end
  
  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def treasure_params
      params.require(:treasure).permit(:xp, :loot, :power, :chance, :image, :body)
    end
end
