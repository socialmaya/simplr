class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :reset_page_num, only: [:index, :show]
  
  def add_image
  end

  # GET /posts
  # GET /posts.json
  def index
    @all_items = Post.global.reverse
    @items = paginate @all_items
    @char_codes = char_codes @items
    @post = Post.new
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    if @post
      @post_shown = true
      @comment = Comment.new
      @comments = @post.comments
    else
      redirect_to '/404'
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
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
        format.html { redirect_to (@post.group.present? ? @post.group : posts_url),
          notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        Tag.extract @post
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def reset_page_num
      reset_page
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:user_id, :body, :image)
    end
end
