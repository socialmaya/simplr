class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :invite_only
  
  def toggle_mini_index
    @post = Post.find_by_id params[:post_id]
    @comments = @post.comments.last 5 if @post
    @comment = Comment.new
  end

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    @replying = true
    @reply = Comment.new
    @replies = @comment.replies
    @comment_shown = true
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
    @editing = true
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)
    @comment.post_id = params[:post_id]
    @comment.comment_id = params[:comment_id]
    if current_user
      @comment.user_id = current_user.id
    else
      @comment.anon_token = anon_token
    end
    if @comment.save
      Tag.extract @comment
      if @comment.comment
        Note.notify :comment_reply, @comment.comment, @comment.comment.user, current_identity \
          unless current_user.eql? @comment.comment.user \
          or (anon_token and anon_token.eql? @comment.anon_token)
        redirect_to @comment.comment
      elsif @comment.post
        @post = @comment.post
        Note.notify :post_comment, @post, @post.user, current_identity \
          unless current_user.eql? @post.user \
          or (anon_token and anon_token.eql? @post.anon_token)
        # notify everyone else that's commented on the post
        for user in @post.commenters
          Note.notify :also_commented, @post, user, current_identity unless current_user and current_user.eql? user
        end
        # only redirects if not ajax
        unless params[:ajax_req]
          redirect_to @post
        else
          @comment = Comment.new
          @comments = @post.comments.last 5
        end
      end
    else
      redirect_to :back
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        Tag.extract @comment
        format.html { redirect_to @comment }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @post = @comment.post
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to @post }
    end
  end

  private
    def invite_only
      unless invited?
        redirect_to invite_only_path
      end
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:user_id, :post_id, :comment_id, :body, :image)
    end
end
