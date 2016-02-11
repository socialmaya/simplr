class SearchController < ApplicationController
  before_action :invite_only
  
  def toggle_dropdown
    @tags = Tag.trending
  end
  
  def index
    @query = params[:query].present? ? params[:query] : session[:query]
    session[:query] = @query; @results = []; @results_shown = true
    if @query.present?
      # to display different result types found for each query
      @result_types = { group: 0, user: 0, post: 0, comment: 0 }
      # loops through each model and through each item in each model
      [Group, User, Post, Comment].each do |_class|
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
          case @query
          when "groups"
            match = true if _class.eql? Group
          when "users"
            match = true if _class.eql? User
          when "groups and users", "users and groups"
            match = true if [Group, User].include? _class
          end
          if match
            @results << item
            @result_types[item.class.to_s.downcase.to_sym] +=1
          end
        end
      end
    end
  end

  private
    # scans specific peices of text for match
    def scan_text item, query, match=false
      [:body, :name, :anon_token].each do |sym|   
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
    
    def invite_only
      unless invited?
        redirect_to invite_only_path
      end
    end
end
