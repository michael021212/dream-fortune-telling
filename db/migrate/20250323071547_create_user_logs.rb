class CreateUserLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :user_logs do |t|
      t.string :line_user_id, null: false
      t.datetime :last_request_at, null: false
      t.integer :warning_count, null: false, default: 0

      t.timestamps
    end

    add_index :user_logs, :line_user_id
    add_index :user_logs, :last_request_at
  end
end
