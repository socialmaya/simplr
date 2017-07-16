class WikisController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :history]
  def index
  end
  
  def show
  end
  
  def edit
  end
  
  def create
  end
  
  def update
  end
  
  def destroy
  end
  
  def history
  end
  
  private

  # Use callbacks to share common setup or constraints between actions.
  def set_wiki
    @wiki = Wiki.find_by_id(params[:id])
    redirect_to '/404' unless @wiki
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def wiki_params
    params.require(:wiki).permit(:user_id, :title, :body, pictures_attributes: [:id, :wiki_id, :image])
  end
end
