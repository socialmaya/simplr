class NotesController < ApplicationController
  def index
    @notes = if current_user
      current_user.notes.unseen
    else
      Note.where(anon_token: anon_token).unseen
    end
  end
end
