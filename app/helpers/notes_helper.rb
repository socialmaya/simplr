module NotesHelper
  def namify_note_message note
    if note.message and note.message.include? "Someone"
      if User.find_by_id note.sender_id
        return note.message.gsub("Someone", User.find(note.sender_id).name)
      elsif note.sender_token.present?
        return note.message.gsub("Someone", "Someone anonymously")
      end
    else
      return note.message
    end
  end
  
  def currently_unseen_notes
    if current_user
      current_user.notes.unseen
    else
      Note.where(anon_token: anon_token).unseen
    end
  end
end
