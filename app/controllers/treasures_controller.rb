class TreasuresController < ApplicationController
  before_action :hidden_treasure, except: [:kanye, :kopimi]
  
  # sacred kopimist ritual
  def kopimi
    @kopi = ""
    for i in 1..3
      word = $name_generator.next_name.downcase
      word << " " unless i.eql? 3
      @kopi << word
    end
  end
  
  # sacred copying
  def kopi
  end
  
  # sacred pasting
  def pasta
  end
  
  # sacred remixing of information
  def remix
    @unremixed_text = params[:unremixed_text].to_s; @remixed_text = ""
    words = @unremixed_text.split(" ")
    for word in words
      beginning = word[0..word.size/2-1]
      end_of_word = word[word.size/2..-1]
      words << beginning << end_of_word
      words.delete word
    end
    words = words.sample words.size
    (0..words.size-1).step(2) do |i|
      if words[i].nil? or words[i+1].nil?
        break
      end
      @remixed_text << "#{words[i]+words[i+1]}"
      @remixed_text << " " unless i.eql? words.size-1
    end
  end
  
  # sacred sharing of info
  def kopi_share
  end
  
  # new form for kopi_share
  def new_kopi_share
  end
  
  # kanye quotes
  def kanye
  end
  
  # hype other users
  def hype
    @user = User.find_by_id params[:user_id]
    hype_nugget = Treasure.new treasure_type: :hype, power: :hype_others,
      user_id: @user.id, giver_id: current_user.id
    if hype_nugget.save
      Note.notify :hype_received, hype_nugget.unique_token, @user, current_user
    end
    redirect_to :back
  end
  
  def powers
    @powers = current_user.active_powers.reverse
  end

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
    def hidden_treasure
      unless current_user and current_user.has_power? 'discover'
        redirect_to '/404' unless dev?
      end
    end
    
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
