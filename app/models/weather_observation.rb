class WeatherObservation < ApplicationRecord
  belongs_to :daily_log

  validates :temperature_c,
            numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 60 },
            allow_nil: true
  validates :humidity_pct,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_nil: true
  validates :pressure_hpa,
            numericality: { greater_than_or_equal_to: 800, less_than_or_equal_to: 1100 },
            allow_nil: true

  validate :observed_at_required_if_snapshot_present

  private

  def observed_at_required_if_snapshot_present
    if snapshot.present? && observed_at.blank?
      errors.add(:observed_at, "must be present if snapshot is provided")
    end
  end
end
