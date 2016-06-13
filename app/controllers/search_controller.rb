class SearchController < ApplicationController
  before_action :secure_search
  
  def toggle_dropdown
    @tags = Tag.trending
  end
  
  def index
    @query = params[:query].present? ? params[:query] : session[:query]
    session[:query] = @query; @results = []; @results_shown = true
    if @query.present?
      # to display different result types found for each query
      @result_types = { group: 0, user: 0, bot: 0, post: 0, comment: 0 }
      # loops through each model and through each item in each model
      [Group, User, Bot, Post, Comment].each do |_class|
        _class.all.reverse.each do |item|
          match = false; match_by_tag = false
          # scans all text for query
          match = true if scan_text item, @query
          # scans all items for matching tags
          if item.respond_to? :tags
            item.tags.each do |tag|
              if @query.eql? tag.tag or "##{@query}".eql? tag.tag
                match_by_tag = true
                match = true
              end
            end
          end
          # scans comments of current item
          if item.respond_to? :comments and not _class.eql? User
            item.comments.each do |comment|
              match = true if scan_text comment, @query
              break if match
            end
          end
          # a case for keywords used
          case @query
          when "posts", "Posts"
            match = true if _class.eql? Post and not item.group
          when "groups", "Groups"
            match = true if _class.eql? Group
          when "users", "Users"
            match = true if _class.eql? User
          when "groups and users", "users and groups"
            match = true if [Group, User].include? _class
          # first treasure found, first power unlocked
          when "discover"
            if current_user
              treasure = current_user.treasures.new power: 'discover'
              # can now find hidden treasure on the site and unlock powers
              if treasure.save
                @discover = true
                break
              end
            end
          end
          if match
            @results << item
            @result_types[item.class.to_s.downcase.to_sym] +=1
          end
        end
        # to prevent duplicate treasures from being created
        break if @discover
      end
      # removes any types not found at all, for display to view with/without commas
      @result_types.each { |key, val| @result_types.delete(key) if val.zero?  }
    end
  end

  private
    # scans specific peices of text for match
    def scan_text item, query, match=false
      [:body, :name, :anon_token, :unique_token].each do |sym|   
        if item.respond_to? sym and item.send(sym).present? 
          match = true if scan item.send(sym), query
        end
      end
      return match
    end
    
    # scans text word by word for match
    def scan text, query, match=false
      for word in text.split(" ")
        for key_word in query.split(" ")
          if key_word.size > 2
            if word.eql? key_word or word.eql? key_word.downcase or word.eql? key_word.capitalize \
              or word.include? key_word.downcase or word.include? key_word.capitalize
              match = true
            end
          end
        end
      end
      return match
    end
    
    def secure_search
      unless invited? or anrcho?
        redirect_to invite_only_path
      end
    end
end
