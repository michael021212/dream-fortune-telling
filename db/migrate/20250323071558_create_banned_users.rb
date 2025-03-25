class CreateBannedUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :banned_users do |t|
      t.string :line_user_id, null: false
      t.datetime :banned_at, null: false
      t.string :reason, null: false

      t.timestamps
    end

    add_index :banned_users, :line_user_id, unique: true
  end
end
