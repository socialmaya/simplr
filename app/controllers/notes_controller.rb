class NotesController < ApplicationController
  before_action :current_notes, only: [:index, :destroy]
  before_action :dev_only, only: [:dev_index]
  
  def dev_index
    @notes = Note.all.last(20).reverse
  end
  
  def show
    @note = Note.find(params[:id])
  end
  
  def index
    @notes = @notes.last(10).reverse
  end
  
  private
  
  def dev_only
    redirect_to '/404' unless dev?
  end
  
  def current_notes
    @notes = if current_user
      current_user.notes
    else
      Note.where(anon_token: anon_token)
    end
  end
end
