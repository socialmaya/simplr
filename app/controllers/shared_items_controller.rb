class SharedItemsController < ApplicationController
  before_action :invite_only
  before_action :set_shared_item, only: [:update, :destroy, :show, :edit]
  before_action :new_shared_item, only: [:show_form]

  def show_form
    @item_library = ItemLibrary.find_by_id params[:item_library_id]
  end

  def index
    @item_libraries = SharedItem.all
  end

  def create
    @item_library = ItemLibrary.find_by_id params[:item_library_id]
    @shared_item = @item_library.shared_items.new(shared_item_params)
    if @shared_item.save
      redirect_to @shared_item.item_library
    else
      redirect_to :back
    end
  end

  def update
  end

  def destroy
  end

  def edit
    @editing = true
  end

  private

  def new_shared_item
    @shared_item = SharedItem.new
  end

  def set_shared_item
    @shared_item = SharedItem.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shared_item_params
    params.require(:shared_item).permit(:name, :description)
  end

  def invite_only
    unless invited?
      redirect_to sessions_new_path
    end
  end
end
