class User < ApplicationRecord
  has_many :calendar_events, dependent: :destroy
  has_many :watches, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :google_id, presence: true, uniqueness: true
  validates :phone_number, format: { with: /\A\+?[1-9]\d{1,14}\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :notification_method, inclusion: { in: %w[email sms both] }, allow_nil: true
  validate :sms_requires_consent

  def token_expired?
    token_expires_at.nil? || token_expires_at <= Time.current
  end

  private

  def sms_requires_consent
    if sms_enabled? && !sms_consent?
      errors.add(:sms_enabled, "cannot be enabled without SMS consent. Please check the consent box above.")
    end
  end

  def self.from_omniauth(auth)
    where(google_id: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.google_id = auth.uid
    end
  end

  def update_tokens(credentials)
    update(
      access_token: credentials.token,
      refresh_token: credentials.refresh_token || refresh_token,
      token_expires_at: credentials.expires_at ? Time.at(credentials.expires_at) : nil
    )
  end
end
