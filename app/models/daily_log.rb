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
end
