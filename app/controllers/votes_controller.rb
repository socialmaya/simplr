class VotesController < ApplicationController
  before_filter :bots_to_404
  
  def new_up_vote
    @proposal = Proposal.find_by_unique_token(params[:token])
    if @proposal and not @proposal.anon_token.eql? anon_token
      @up_vote = Vote.up_vote(@proposal, anon_token)
    end
  end
  
  def new_down_vote
    @proposal = Proposal.find_by_unique_token(params[:token])
    if @proposal and not @proposal.anon_token.eql? anon_token
      @down_vote = Vote.down_vote(@proposal, anon_token)
    end
  end
  
  def cast_up_vote
    @proposal = Proposal.find_by_unique_token(params[:token])
    @up_vote = Vote.up_vote(@proposal, anon_token, params[:body])
    Tag.extract @up_vote
  end
  
  def cast_down_vote
    @proposal = Proposal.find_by_unique_token(params[:token])
    @down_vote = Vote.down_vote(@proposal, anon_token, params[:body])
    Tag.extract @down_vote
  end
  
  def reverse
    @vote = Vote.find_by_unique_token params[:token]
    if @vote.could_be_reversed? anon_token
      @vote.votes.create flip_state: 'down', token: anon_token
      if @vote.votes_to_reverse <= 0
        if @vote.up?
          @vote.proposal.update ratified: false
        elsif @vote.down?
          @vote.proposal.update requires_revision: false
        end
        @vote.update verified: false
        @vote.votes.destroy_all
      end
    end
    redirect_to :back
  end
  
  def verify
    if cookies[:simple_captcha_validated].present?
      @vote = Vote.find_by_unique_token params[:token]
      if @vote.verifiable? anon_token and not @vote.proposal.requires_revision
        @vote.update verified: true
        @vote.proposal.evaluate
      end
    end
    redirect_to :back
  end
  
  def confirm_humanity
    if simple_captcha_valid?
      cookies.permanent[:simple_captcha_validated] = true
    end
    redirect_to :back
  end
  
  def show
    @vote = Vote.find_by_unique_token params[:token]
    @comments = @vote.comments
    @new_comment = Comment.new
  end
  
  private
    def bots_to_404
      redirect_to '/404' if request.bot?
    end
end
