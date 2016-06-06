class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :secure_user, only: [:edit, :update, :destroy]
  before_action :dev_only, only: [:index]
  before_action :invite_only
  
  def hide_featured_users
    cookies.permanent[:hide_featured_users] = true
  end
  
  def new
    unless current_user
      reset_page
      @user = User.new
      # gets preview items for invitee
      @all_items = Post.all.reverse
      @items = paginate @all_items
      @char_codes = char_codes @items
      # records user viewing posts
      @items.each {|item| seent item}
      # records current time for last visit
      record_last_visit
    end
  end
  
  def create
    @user = User.new(user_params)
    # access rights from invite
    grant_access_rights
    if @user.save
      if params[:remember_me]
        cookies.permanent[:auth_token] = @user.auth_token
      else
        cookies[:auth_token] = @user.auth_token
      end
      cookies.permanent[:logged_in_before] = true
      redirect_to root_url
    else
      redirect_to :back
    end
  end

  def index
    # creates array of active users and sorts by date last active
    active_users = []; User.where.not(last_active_at: nil).each { |user| active_users << user }
    active_users.sort_by! { |user| user.last_active_at }.reverse!
    # creates array of inactive users and just sorts by time of creation
    inactive_users = []; User.where(last_active_at: nil).each { |user| inactive_users << user }
    inactive_users.sort!.reverse!
    # adds both arrays together for finale
    @users = active_users + inactive_users
  end

  def show
    if @user
      @post = Post.new
      @posts = @user.posts.last(10).reverse
      @user_shown = true
      # records being seen
      seent @user
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        Tag.extract @user
        format.html { redirect_to @user }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end

  private
    def grant_access_rights
      # grants dev powers sent with invite
      if cookies[:grant_dev_access]
        # deletes to prevent creation of multiple devs
        cookies.delete(:grant_dev_access)
        @user.dev = true
      end
      # grants power of gatekeeper
      if cookies[:grant_gk_access]
        cookies.delete(:grant_gk_access)
        @user.gatekeeper = true
      end
    end
    
    def invite_only
      unless invited?
        redirect_to invite_only_path
      end
    end
    
    def dev_only
      redirect_to '/404' unless dev?
    end
    
    def secure_user
      set_user; redirect_to '/404' unless current_user.eql? @user or dev?
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :image, :body, :password, :password_confirmation)
    end
end
