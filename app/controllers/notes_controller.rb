class NotesController < ApplicationController
  def index
    @notes = if current_user
      current_user.notes.reverse
    else
      Note.where(anon_token: anon_token).reverse
    end
  end
end
