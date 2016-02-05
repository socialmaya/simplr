class SearchController < ApplicationController
  before_action :invite_only
  
  def toggle_dropdown
    @tags = Tag.trending
  end
  
  def index
    @query = params[:query].present? ? params[:query] : session[:query]
    session[:query] = @query; @results = []; @results_shown = true
    if @query.present?
      @result_types = { group: 0, user: 0, post: 0, comment: 0 }
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
    def scan_text item, query, match=false
      if item.respond_to? :body
        match = true if item.body.present? and scan item.body, query
      end
      if item.respond_to? :name
        match = true if item.name.present? and scan item.name, query
      end
      if item.respond_to? :anon_token
        match = true if item.anon_token.present? and scan item.anon_token, query
      end
      return match
    end

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
