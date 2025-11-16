class CreateWatches < ActiveRecord::Migration[7.2]
  def change
    create_table :watches do |t|
      t.references :user, null: false, foreign_key: true
      t.string :channel_id, null: false
      t.string :resource_id, null: false
      t.datetime :expiration, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :watches, :channel_id, unique: true
    add_index :watches, [:user_id, :active]
    add_index :watches, :expiration
  end
end
