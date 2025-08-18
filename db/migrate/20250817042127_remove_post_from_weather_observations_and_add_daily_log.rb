class RemovePostFromWeatherObservationsAndAddDailyLog < ActiveRecord::Migration[7.2]
  def change
    # weather_observationsテーブルからpost_idを削除
    remove_reference :weather_observations, :post, foreign_key: true, index: true

    # weather_observationsテーブルにdaily_log_idを追加
    add_reference :weather_observations, :daily_log, foreign_key: true, index: true
  end
end