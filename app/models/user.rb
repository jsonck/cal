class User < ApplicationRecord
  has_many :calendar_events, dependent: :destroy
  has_many :watches, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :google_id, presence: true, uniqueness: true

  def token_expired?
    token_expires_at.nil? || token_expires_at <= Time.current
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
