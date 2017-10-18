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
  mount_uploader :video, VideoUploader
  
  scope :global, -> { where group_id: nil }
  scope :forrest_only, -> { where forrest_only: true }
  scope :un_invited, -> { where un_invited: true }
  
  def _likes
    self.likes.where love: nil, whoa: nil, zen: nil
  end
  
  def loves
    self.likes.where love: true
  end
  
  def zens
    self.likes.where zen: true
  end
  
  def whoas
    self.likes.where whoa: true
  end
  
  def self.preview_posts forrest_only=nil
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
    # only get foc posts when forrest_only
    posts.delete_if { |item| !item.forrest_only } if forrest_only
    # sorts posts chronologically
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
  
  def rank user=nil, feed=nil
    ranked = feed.sort_by { |post| post.score(user) }
    return ranked.index(self) + 1 if ranked.include? self
  end
  
  def score user=nil, get_weights=nil
    weight = 0
    weights = {
      likes: 0, likes_plus: 0,
      comments: 0, comments_plus: 0,
      days: 0, days_plus: 0,
      shares: 0,
      views: 0,
      classic: 0
    }
    
    # likes
    for like in self.likes.where.not(user_id: user.id)
      # recent likes on older posts have more weight
      weights[:likes] += ((like.created_at.to_date - self.created_at.to_date).to_i / 4) + 1
      weights[:likes_plus] += 1 if like.whoa or like.love or like.zen
      weights[:likes_plus] += 15 if like.love and like.user_id.eql? 34 # kristin power love
    end # plus one for likes on recent posts to still get valued
    
    # comments
    for comment in self.comments.where.not(user_id: user.id)
      # recent likes on older posts have more weight
      weights[:comments] += ((comment.created_at.to_date - self.created_at.to_date).to_i / 4) + 1
      weights[:comments_plus] += 5 if comment.likes.where.not(user_id: user.id).present?
    end # plus one for likes on recent posts to still get valued
    
    # shares, post shared
    for post in shares
      weights[:shares] += 5
    end
    
    # days since posted
    days_old = (Date.today - self.created_at.to_date).to_i
    # older the post, less the weight
    weights[:days] -= days_old.to_i / 2
    # recent posts get more weight
    weights[:days_plus] += 15 if days_old.to_i < 7
    # still fresh posts get even more weight
    weights[:days_plus] += 25 if days_old.to_i < 5
    
    # views by current user
    view = self.views.where(user_id: user.id).last
    if view
      score_count = view.score_count.to_i
      # more weight taken for views on older posts
      score_count *= 10 if self.created_at > 2.week.ago
      weights[:views] -= view.score_count.to_i
    end
    
    # bring back old classics
    if self.created_at > 3.month.ago    
      weights[:classic] += 50 if rand(Post.all.size/15).eql? 1
    end
    
    # add all weights together
    weights_keys = weights.keys; weights.size.times do |i|
      weight += weights[weights_keys[i]]
    end
    if get_weights
      return weights
    else
      return weight
    end
  end
  
  private
  
  def gen_unique_token
    begin
      self.unique_token = SecureRandom.urlsafe_base64.split('').sample(5).join
    end while Post.exists? unique_token: self.unique_token
  end
    
  def text_or_image?
    if (body.nil? or body.empty?) and (image.url.nil? and not photoset)
      unless original_id and (body.present? or (Post.find_by_id(original_id) \
        and (Post.find(original_id).image.present? or Post.find(original_id).photoset)))
        errors.add(:post, "cannot be empty.") unless video_url
      end
    end
  end
end
