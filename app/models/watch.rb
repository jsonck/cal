class Watch < ApplicationRecord
  belongs_to :user

  validates :channel_id, presence: true, uniqueness: true
  validates :resource_id, presence: true
  validates :expiration, presence: true

  scope :active, -> { where(active: true) }
  scope :expiring_soon, -> { active.where("expiration < ?", 1.day.from_now) }
  scope :expired, -> { active.where("expiration < ?", Time.current) }

  def expired?
    expiration < Time.current
  end

  def expiring_soon?
    expiration < 1.day.from_now
  end

  def deactivate!
    update(active: false)
  end
end
