class NotesController < ApplicationController
  before_action :current_notes, only: [:index, :destroy]
  
  def show
    @note = Note.find(params[:id])
  end
  
  def index
    @notes = @notes.last(10).reverse
  end
  
  private
  
  def current_notes
    @notes = if current_user
      current_user.notes
    else
      Note.where(anon_token: anon_token)
    end
  end
end
