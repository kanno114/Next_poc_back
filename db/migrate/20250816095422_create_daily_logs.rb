class CreateDailyLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :daily_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :score
      t.decimal :sleep_hours, precision: 3, scale: 1
      t.integer :mood
      t.text :memo
      t.references :weather_observation, null: true, foreign_key: true

      t.timestamps
    end

    add_index :daily_logs, [:user_id, :date], unique: true
    add_index :daily_logs, :date

    # 制約の追加
    add_check_constraint :daily_logs, "score >= 0 AND score <= 100", name: "chk_daily_log_score"
    add_check_constraint :daily_logs, "sleep_hours >= 0 AND sleep_hours <= 24", name: "chk_daily_log_sleep"
    add_check_constraint :daily_logs, "mood >= -5 AND mood <= 5", name: "chk_daily_log_mood"
  end
end