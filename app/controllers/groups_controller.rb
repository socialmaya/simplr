class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :secure_group, only: [:edit, :update, :destroy]
  before_action :dev_only, only: [:index]
  before_action :invite_only
  
  def their_groups
    @user = User.find_by_id params[:user_id]
    @groups = @user.my_groups
    redirect_to my_groups_path if @user.eql? current_user
  end

  def my_groups
    @group = Group.new
  end
  
  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all.reverse
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    if @group
      @group_shown = true
      # reset_page
      # @all_items = @group.posts.reverse
      @items = @group.posts.last(10).reverse
      # @char_codes = char_codes @items
      @post = Post.new
      # records posts being seen
      @items.each {|item| seent item}
      # records group being seen
      seent @group
    else
      redirect_to '/404'
    end
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
    @editing = true
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    if current_user
      @group.user_id = current_user.id
    else
      @group.anon_token = anon_token
    end
    respond_to do |format|
      if @group.save
        Tag.extract @group
        format.html { redirect_to @group }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        Tag.extract @group
        format.html { redirect_to @group }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url }
    end
  end

  private
    def invite_only
      unless invited?
        redirect_to invite_only_path
      end
    end
    
    def dev_only
      redirect_to '/404' unless dev?
    end
    
    def secure_group
      set_group
      secure = if current_user
        current_user.id.eql? @group.user_id
      else
        anon_token.eql? @group.anon_token
      end
      redirect_to '/404' unless secure or dev?
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :body, :image)
    end
end
