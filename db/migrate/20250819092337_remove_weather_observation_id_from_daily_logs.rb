class RemoveWeatherObservationIdFromDailyLogs < ActiveRecord::Migration[7.2]
  def change
    remove_reference :daily_logs, :weather_observation, foreign_key: true, index: true
  end
end
