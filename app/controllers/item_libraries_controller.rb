class ItemLibrariesController < ApplicationController
  before_action :invite_only
  before_action :set_item_library, only: [:update, :destroy, :show, :edit]
  before_action :new_item_library, only: [:show_form]

  def show
    @shared_items = @item_library.shared_items
  end

  def index
    @item_libraries = ItemLibrary.all
  end

  def create
    @item_library = ItemLibrary.new(item_library_params)
    if @item_library.save
      redirect_to @item_library
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

  def new_item_library
    @item_library = ItemLibrary.new
  end

  def set_item_library
    @item_library = ItemLibrary.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_library_params
    params.require(:item_library).permit(:name, :body, :image)
  end

  def invite_only
    unless invited?
      redirect_to sessions_new_path
    end
  end
end
