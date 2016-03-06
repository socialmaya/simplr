class TreasuresController < ApplicationController
  # adds option field to treasure form
  def add_option
    session[:option_field] = session[:option_field].to_i + 1
  end

  def loot
    @from_form = true if params[:from_challenge_form]
    @treasure = Treasure.find_by_unique_token(params[:token])
    unless @treasure.looted_by? current_user
      # if a multiple choice question
      if @treasure.options.present?
        params.each do |key, val|
          if key.include? "option_"
            if eval(@treasure.options)[key.to_sym].eql? @treasure.answer
              @overcome = true
            else
              @overcome = false
              break
            end
          end
        end
      # if a simple question (single choice answer)
      elsif @treasure.answer.present? and params[:answer]
        if params[:answer].eql? @treasure.answer
          @overcome = true
        end
      # if no challenge is present
      elsif not @treasure.answer.present?
        @overcome = true
      end
      current_user.loot @treasure if @overcome
    end
  end
  
  def create
    @treasure = Treasure.new(treasure_params)
    # builds hash of options from params, initializes with correct answer
    options = { option_0: @treasure.answer }
    params.each do |key, val|
      # if option for multiple choice
      if key.include? "option_"
        options[key.to_sym] = val
      end
    end
    # saves options hash as string if more than one answer
    @treasure.options = shuffle(options).to_s if options.size > 1
    if @treasure.save
      redirect_to show_treasure_path @treasure.unique_token
    else
      flash[:error] = "Invalid input"
      redirect_to :back
    end
  end
  
  def update
  end
  
  def show
    @treasure = Treasure.find_by_unique_token(params[:token])
    redirect_to '/404' if @treasure.nil?
  end
  
  private
    # shuffles answer options so correct one isn't always first
    def shuffle options
      vals = options.values.shuffle
      i=0; options.each do |key, val|
        options[key] = vals[i]; i+=1
      end
      return options
    end
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def treasure_params
      params.require(:treasure).permit(:name, :xp, :power, :treasure_type, :chance, :image, :body, :answer)
    end
end
