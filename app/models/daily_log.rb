class DailyLog < ApplicationRecord
  belongs_to :user
  has_one :weather_observation, dependent: :destroy

  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id, message: "この日付のログは既に存在します" }

  validates :score,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_nil: true
  validates :sleep_hours,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 24 },
            allow_nil: true
  validates :mood,
            numericality: { greater_than_or_equal_to: -5, less_than_or_equal_to: 5 },
            allow_nil: true

  scope :recent, -> { order(date: :desc) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }

  def self.find_or_initialize_by_user_and_date(user, date)
    find_or_initialize_by(user: user, date: date)
  end

  def jst_range
    # 日本時間の当日の範囲を返す
    start_time = date.beginning_of_day.in_time_zone('Asia/Tokyo')
    end_time = date.end_of_day.in_time_zone('Asia/Tokyo')
    start_time..end_time
  end
end
