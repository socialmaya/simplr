module VotesHelper
  def humanity_confirmed?
    cookies[:simple_captcha_validated].present? or current_user
  end
  
  def recently_up_voted? proposal
    vote = proposal.up_votes.find_by_anon_token(anon_token)
    return (up_voted? proposal and vote.created_at > 1.hour.ago)
  end
  
  def up_voted? proposal
    vote = proposal.up_votes.find_by_anon_token(anon_token)
    if vote and vote.body.present?
      return vote
    else
      return nil
    end
  end
  
  def down_voted? proposal
    proposal.down_votes.where(anon_token: anon_token).present?
  end
end
