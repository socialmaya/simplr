class SearchController < ApplicationController
  def index
    @query = params[:query].present? ? params[:query] : session[:query]
    session[:query] = @query; @results = []; @results_shown = true
    if @query.present?
      [User, Post, Comment, Group].each do |_class|
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
          @results << item if match
        end
      end
    end
  end
  
  private
  
  def scan_text item, query, match=false
    if item.respond_to? :body
      match = true if item.body.present? and scan item.body, query
    end
    return match
  end
  
  def scan text, query, match=false
    for word in text.split(" ")
      for key_word in query.split(" ")
        if key_word.size > 2
          if word == key_word.downcase or word == key_word.capitalize \
            or word.include? key_word.downcase or word.include? key_word.capitalize
            match = true
          end
        end
      end
    end
    return match
  end
end
