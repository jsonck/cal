class AddSmsConsentToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :sms_consent, :boolean, default: false, null: false
    add_column :users, :sms_consent_date, :datetime
  end
end
