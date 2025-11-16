class CreateEventReminders < ActiveRecord::Migration[7.2]
  def change
    create_table :event_reminders do |t|
      t.references :calendar_event, null: false, foreign_key: true
      t.integer :minutes_before, null: false
      t.boolean :sent, default: false, null: false
      t.string :notification_type # email, sms, or both

      t.timestamps
    end

    add_index :event_reminders, [:calendar_event_id, :minutes_before]
    add_index :event_reminders, [:sent, :created_at]
  end
end
