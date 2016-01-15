class NotesController < ApplicationController
  before_action :current_notes, only: [:index, :destroy]
  def index
    @notes = @notes.last(10).reverse
  end
  
  def destroy
    @notes.destroy_all
    redirect_to :back
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
