module Weather
  class WeatherService
    def self.create_or_update_weather_observation(daily_log:, lat:, lng:)
      if daily_log.weather_observation.present?
        # 既存の投稿の場合
        fetcher = Weather::FetcherCurrent.new(lat:, lng:, timezone: "Asia/Tokyo")
        weather_data = fetcher.call

        daily_log.weather_observation.update(
          temperature_c: weather_data[:temperature_c],
          humidity_pct: weather_data[:humidity_pct],
          pressure_hpa: weather_data[:pressure_hpa],
          observed_at: Time.zone.parse(weather_data[:time]),  # 修正
          snapshot: weather_data[:raw]
        )
      else
        # 新規投稿の場合
        fetcher = Weather::FetcherCurrent.new(lat:, lng:, timezone: "Asia/Tokyo")
        weather_data = fetcher.call

        daily_log.create_weather_observation(
          temperature_c: weather_data[:temperature_c],
          humidity_pct: weather_data[:humidity_pct],
          pressure_hpa: weather_data[:pressure_hpa],
          observed_at: Time.zone.parse(weather_data[:time]),  # 修正
          snapshot: weather_data[:raw]
        )
      end
    end
  end
end