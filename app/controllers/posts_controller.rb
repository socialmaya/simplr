class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :share,
    :hide, :open_menu, :close_menu, :add_photoset]
  before_action :secure_post, only: [:edit, :update, :destroy]
  before_action :reset_page_num, only: [:index, :show]
  before_action :invite_only
  before_action :bots_to_404
  
  def open_menu
  end
  
  def close_menu
  end
  
  def add_group_id
  end
  
  def add_image
  end
  
  def add_photoset
  end
  
  def remove_picture
    @picture_id = params[:picture_id]
    @picture = Picture.find_by_id @picture_id
    @picture.destroy
  end
  
  def hide
    @post.update hidden: true
    redirect_to root_url
  end
  
  def share
    @dup_post = @post.dup
    @dup_post.user_id = current_user.id
    # assigns id of shared post or the original if present
    @dup_post.original_id = if @post.original_id
      @post.original_id
    else
      @post.id
    end
    @dup_post.group_id = nil
    if @dup_post.save
      Tag.extract @dup_post
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
      Post.all.reverse
    end
    @items = paginate @all_items
    @char_codes = char_codes @items
    @post = Post.new
    # records user viewing posts
    @items.each {|item| seent item}
    # records current time for last visit
    record_last_visit
  end

  def show
    if @post
      @post_shown = true
      @comment = Comment.new
      @comments = @post.comments
      # manifests table flipping/resetting bot
      Bot.manifest_bots [:reset_table, :grow],
        { comments: @comments, page: request.original_url }
      @likes = @post.likes
      # records views
      seent @post
      # gets views
      @views = @post.views
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
    @group = Group.find_by_id params[:group_id]
    # check to see if user is a member of group if ones selected
    @post.group_id = @group.id if current_user and @group and \
      (current_user.my_groups.include? @group or @group.user.eql? current_user)
    if current_user
      @post.user_id = current_user.id
    else
      @post.anon_token = anon_token
    end
    # sets as photoset for validation
    if params[:pictures]
      @post.photoset = true
    end
    respond_to do |format|
      if @post.save
        if params[:pictures]
          # builds photoset for post
          params[:pictures][:image].each do |image|
            @post.pictures.create image: image
          end
        end
        Tag.extract @post #extracts any hashtags along with their position in the text
        format.html { redirect_to (@post.group.present? ? @post.group : root_url) }
      else
        format.html { redirect_to root_url }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        if params[:pictures]
          params[:pictures][:image].each do |image|
            @post.pictures.create image: image
          end
        end
        Tag.extract @post
        format.html { redirect_to @post }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to root_url }
    end
  end

  private
    def bots_to_404
      redirect_to '/404' if request.bot?
    end
    
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
      params.require(:post).permit(:user_id, :group_id, :body, :image, pictures_attributes: [:id, :post_id, :image])
    end
end
