class DailyLogsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date, :date
  attribute :score, :integer
  attribute :sleep_hours, :integer
  attribute :mood, :integer
  attribute :memo, :string

  validates :date, presence: true
  validates :score, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :sleep_hours, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }
  validates :mood, presence: true,
            numericality: { greater_than_or_equal_to: -5, less_than_or_equal_to: 5 }
  validates :memo, presence: true

  def self.from_params(params)
    new(
      date: params[:date].to_date,
      score: params[:score],
      sleep_hours: params[:sleep_hours],
      mood: params[:mood],
      memo: params[:memo],
    )
  end

  def to_daily_log_attributes
    attributes = {
      date: date,
      score: score,
      sleep_hours: sleep_hours,
      mood: mood,
      memo: memo
    }

    attributes
  end
end