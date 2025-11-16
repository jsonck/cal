class CreateCalendarEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :calendar_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event_id
      t.string :summary
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :reminder_sent, default: false

      t.timestamps
    end

    add_index :calendar_events, [:user_id, :event_id], unique: true
    add_index :calendar_events, :start_time
  end
end
