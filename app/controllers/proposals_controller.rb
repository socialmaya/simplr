class ProposalsController < ApplicationController
  before_filter :set_proposal, only: [:old_versions, :show]
  before_filter :bots_to_404
  
  def tutorial
  end
  
  def old_versions
    @old_versions = @proposal.old_versions
  end
  
  def load_section_links
    @group = Group.find_by_token(params[:group_token])
  end
  
  def add_image
  end
  
  def index
    if current_user
      # if user had visited social_maya via anrcho
      cookies.delete(:auth_token)
    end
    # for use in development
    cookies.permanent[:at_anrcho] ||= true.to_s
    build_feed :main
  end
  
  def new
    @proposal = Proposal.new
    @parent_proposal = Proposal.find_by_id(params[:proposal_id])
    @group = Group.find_by_id(params[:group_id])
  end
  
  def create
    @proposal = Proposal.new(proposal_params)
    @proposal.group_id = params[:group_id]
    @proposal.anon_token = anon_token
    build_action
    if @proposal.save
      Tag.extract @proposal
      if @proposal.proposal
        Note.notify :revision_submitted, @proposal.proposal.unique_token
        redirect_to show_proposal_path(token: @proposal.proposal.unique_token, revisions: true)
      elsif @proposal.group
        redirect_to show_group_path(@proposal.group.unique_token)
      else
        redirect_to proposals_path
      end
    else
      redirect_to :back
    end
  end
  
  def show
    @group = @proposal.group if @proposal
    if @proposal
      Note.create message: "Request protocol: #{request.protocol}"
      @proposal_shown = true
      seent @proposal
      
      # gets all votes for and against
      @up_votes = @proposal.up_votes
      @down_votes = @proposal.down_votes
      @votes = @proposal.votes.reverse
      
      # gets all comments/discussion
      @comments = @proposal.comments
      @comment = Comment.new
      
      # gets any revisions to proposal
      @revisions = @proposal.proposals
      @revision = Proposal.new
      
      @old_versions = @proposal.old_versions
      
      if params[:revisions] and @proposal.requires_revision
        @show_revisions = true
      elsif params[:comments] or @votes.empty?
        @show_comments = true
      else
        @show_votes = true
      end
      
      @proposal.evaluate
    else
      redirect_to '/404'
    end
  end
  
  # Proposal sections: :voting, :revision, :ratified
  def switch_section
    @group = Group.anrcho.find_by_unique_token params[:group_token]
    build_feed params[:section], @group
  end
  
  # Sub sections: :votes, :comments
  def switch_sub_section
    redirect_to :back
  end
  
  private
    def set_proposal
      @proposal = Proposal.find_by_unique_token(params[:token])
    end
    
    def build_feed section, group=nil
      build_proposal_feed section, group
    end
    
    def build_action
      action = params[:proposal][:action]
      action = params[:proposal_action] unless action.present?
      case (action.present? ? action : "").to_sym
      when :add_locale, :meetup
        @proposal.misc_data = request.remote_ip.to_s
      when :revision
        @proposal.action = "revision"
        @proposal.proposal_id = params[:proposal_id]
        @proposal.revised_action = params[:revised_action]
        @proposal.version = Proposal.find(params[:proposal_id]).version.to_i + 1
      end
    end
    
    def proposal_params
      params[:proposal].permit(:title, :body, :action, :image, :misc_data)
    end
    
    def bots_to_404
      redirect_to '/404' if request.bot?
    end
end
