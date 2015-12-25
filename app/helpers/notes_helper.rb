module NotesHelper
  def currently_unseen_notes
    if current_user
      current_user.notes.unseen
    else
      Note.where(anon_token: anon_token).unseen
    end
  end
end
