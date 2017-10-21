class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  belongs_to :comment
  belongs_to :proposal
  belongs_to :like
  belongs_to :vote
  
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  before_create :gen_unique_token
  
  validate :unique_to_item?, on: :create
  
  scope :loves, -> { where love: true }
  scope :whoas, -> { where whoa: true }
  scope :zens, -> { where zen: true }
  
  def _likes
    self.likes.where love: nil, whoa: nil, zen: nil
  end

  private
  
  def unique_to_item?
    if self.post_id
      if self.user_id
        if Post.find(self.post_id).views.where(user_id: self.user_id).present?
          errors.add :like, "Not unique like by user"
        end
      elsif self.anon_token
        if Post.find(self.post_id).views.where(anon_token: self.anon_token).present?
          errors.add :like, "Not unique like by anon"
        end
      end
    elsif self.proposal_id
      if self.user_id
        if Proposal.find(self.proposal_id).views.where(user_id: self.user_id).present?
          errors.add :like, "Not unique like of motion by user"
        end
      elsif self.anon_token
        if Proposal.find(self.proposal_id).views.where(anon_token: self.anon_token).present?
          errors.add :like, "Not unique like of motion by anon"
        end
      end
    end
  end
  
  def gen_unique_token
    self.unique_token = SecureRandom.urlsafe_base64
  end
end
