class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :share, :open_menu, :close_menu]
  before_action :secure_post, only: [:edit, :update, :destroy]
  before_action :reset_page_num, only: [:index, :show]
  before_action :invite_only
  
  def open_menu
  end
  
  def close_menu
  end
  
  def add_image
  end
  
  def share
    @dup_post = @post.dup
    @dup_post.user_id = current_user.id
    @dup_post.original_id = if @post.original_id
      @post.original_id
    else
      @post.id
    end
    @dup_post.body = ""
    @dup_post.group_id = nil
    if @dup_post.save
      Note.notify :post_share, @dup_post, (@post.user ? @post.user : @post.anon_token), current_user
      redirect_to root_url
    else
      redirect_to :back
    end
  end

  def index
    @you_are_home = true
    @all_items = if current_user
      current_user.feed
    else
      Post.global.reverse
    end
    @items = paginate @all_items
    @char_codes = char_codes @items
    @post = Post.new
    # records user viewing posts
    @items.each {|item| seent item}
  end

  def show
    if @post
      @post_shown = true
      @comment = Comment.new
      @comments = @post.comments
      seent @post
    else
      redirect_to '/404'
    end
  end

  def new
    @post = Post.new
  end

  def edit
    @editing = true
  end

  def create
    @post = Post.new(post_params)
    @post.group_id = params[:group_id]
    if current_user
      @post.user_id = current_user.id
    else
      @post.anon_token = anon_token
    end
    respond_to do |format|
      if @post.save
        Tag.extract @post #extracts any hashtags along with their position in the text
        format.html { redirect_to (@post.group.present? ? @post.group : root_url) }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        Tag.extract @post
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url }
    end
  end

  private
    def invite_only
      unless invited?
        redirect_to invite_only_path
      end
    end
    
    def secure_post
      set_post
      unless current_user.eql? @post.user or (anon_token and anon_token.eql? @post.anon_token) or dev?
        redirect_to '/404'
      end
    end
    
    def reset_page_num
      reset_page
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find_by_id(params[:id])
      redirect_to '/404' unless @post
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:user_id, :body, :image)
    end
end
