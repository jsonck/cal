class AddPhoneAndPreferencesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :phone_number, :string
    add_column :users, :sms_enabled, :boolean, default: false
    add_column :users, :notification_method, :string, default: 'both' # email, sms, or both
  end
end
