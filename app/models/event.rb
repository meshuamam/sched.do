class Event < ActiveRecord::Base
  attr_accessible :name, :suggestion, :suggestions_attributes, :uuid

  belongs_to :user
  has_many :suggestions
  has_many :votes, through: :suggestions
  has_many :invitations
  has_many :users, through: :invitations, source: :invitee, source_type: 'User'
  has_many :guests, through: :invitations, source: :invitee, source_type: 'Guest'
  has_many :groups, through: :invitations, source: :invitee, source_type: 'Group'

  validates :name, presence: { message: 'This field is required' }
  validates :user_id, presence: true
  validates :uuid, presence: true

  accepts_nested_attributes_for :suggestions,
    allow_destroy: true

  after_create :create_yammer_activity_for_new_event
  before_validation :generate_uuid, :on => :create
  before_validation :reject_blank_suggestions, :set_first_suggestion

  def build_suggestions
    suggestions[0] ||= Suggestion.new
    suggestions[1] ||= Suggestion.new
  end

  def invitees
    group = [user] + users + guests
    group.sort{|a, b| b.created_at <=> a.created_at }
  end

  def invitees_for_json
    invitees.map { |i| { name: i.name, email: i.email } }
  end

  def generate_uuid
    self.uuid = SecureRandom.hex(4)
  end

  def user_owner?(user)
    self.user == user
  end

  def user_invited?(user)
    invitees.include?(user)
  end

  def user_voted?(user)
    user_votes(user).exists?
  end

  def user_votes(user)
    user.votes.joins(:suggestion).where(suggestions: { event_id: self } )
  end

  def reject_blank_suggestions
    suggestions.reject! do |suggestion|
      suggestion.attributes.all? { |k, v| k == 'event_id' || v.blank? }
    end
  end

  def set_first_suggestion
    if suggestions.all? do |suggestion|
      suggestion.marked_for_destruction? ||
      suggestion.blank?
    end
      suggestions[0] = Suggestion.new
    end
  end

  def to_param
    uuid
  end

  private

  def create_yammer_activity_for_new_event
    user.create_yammer_activity('create', self)
  end
end
