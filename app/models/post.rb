class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :views, dependent: :destroy
  
  validate :text_or_image?, on: :create
  
  mount_uploader :image, ImageUploader
  
  scope :global, -> { where group_id: nil }
  
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
  
  def text_or_image?
    if (self.body.nil? or self.body.empty?) and !self.image.url
      unless self.original_id and (self.body.present? or self.image.present?)
        errors.add(:post, "cannot be empty.")
      end
    end
  end
end
