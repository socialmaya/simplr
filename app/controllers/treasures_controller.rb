class TreasuresController < ApplicationController
  # adds option field to treasure form
  def add_option
    session[:option_field] = session[:option_field].to_i + 1
  end

  def loot
    @from_form = true if params[:from_challenge_form]
    @treasure = Treasure.find_by_unique_token(params[:token])
    # should only loot if challenge was overcome
    current_user.loot @treasure
    # redirect_to another treasure if one's available
  end
  
  def create
    @treasure = Treasure.new(treasure_params)
    # builds hash of options from params, initializes with correct answer
    options = { option_0: @treasure.answer }
    params.each do |key, val|
      # if option for multiple choice
      if key.include? "option_"
        options[key] = val
      end
    end
    # saves options hash as string
    @treasure.options = options.to_s
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
    redirect_to '/404' unless @treasure
  end
  
  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def treasure_params
      params.require(:treasure).permit(:xp, :loot, :power, :chance, :image, :body, :answer)
    end
end
