class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :views, dependent: :destroy
  has_many :pictures, dependent: :destroy
  
  accepts_nested_attributes_for :pictures
  
  before_create :gen_unique_token
  
  validate :text_or_image?, on: :create
  
  mount_uploader :image, ImageUploader
  
  scope :global, -> { where group_id: nil }
  
  def _likes
    self.likes.where love: nil, whoa: nil
  end
  
  def loves
    self.likes.where love: true
  end
  
  def whoas
    self.likes.where whoa: true
  end
  
  def self.preview_posts
    posts = []
    # gets all posts by first user from open groups
    for group in Group.where(open: true)
      for post in group.posts
        posts << post if post.user_id.eql? 1
      end
    end
    # gets all anonymous posts
    for post in Post.where(user_id: nil).where.not(anon_token: nil)
      posts << post unless posts.include? post
    end
    # gets all non group proposals not in revision
    for proposal in Proposal.globals.main
      posts << proposal
    end
    posts.sort_by! { |item| item.created_at }
    return posts
  end
  
  def commenters
    _commenters = []
    for comment in self.comments
      unless comment.user and _commenters.include? comment.user or comment.anon_token.present?
        _commenters << comment.user
      end
    end
    return _commenters
  end
  
  def shares
    Post.where original_id: self.id
  end
  
  def original
    Post.find_by_id self.original_id
  end
  
  private
  
  def gen_unique_token
    begin
      self.unique_token = SecureRandom.urlsafe_base64
    end while Post.exists? unique_token: self.unique_token
  end
    
  def text_or_image?
    if (body.nil? or body.empty?) and (image.url.nil? and not photoset)
      unless original_id and (body.present? or (Post.find_by_id(original_id) \
        and (Post.find(original_id).image.present? or Post.find(original_id).photoset)))
        errors.add(:post, "cannot be empty.")
      end
    end
  end
end
