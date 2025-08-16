module Weather
  class WeatherService
    def self.create_or_update_weather_observation(post:, lat:, lng:, event_datetime:)
      if post.weather_observation.present?
        # 既存の投稿の場合
        fetcher = Weather::FetcherOnDate.new(lat:, lng:, date: event_datetime, timezone: "Asia/Tokyo")
        weather_data = fetcher.call
        Rails.logger.info "weather_data: #{weather_data}"

        post.weather_observation.update(
          temperature_c: weather_data[:temperature_c],
          humidity_pct: weather_data[:humidity_pct],
          pressure_hpa: weather_data[:pressure_hpa],
          observed_at: Time.parse(weather_data[:time]).in_time_zone("Asia/Tokyo"),  # 日本時間で保存
          snapshot: weather_data[:raw]
        )
      else
        # 新規投稿の場合
        fetcher = Weather::FetcherOnDate.new(lat:, lng:, date: event_datetime, timezone: "Asia/Tokyo")
        weather_data = fetcher.call
        Rails.logger.info "weather_data: #{weather_data}"

        post.create_weather_observation(
          temperature_c: weather_data[:temperature_c],
          humidity_pct: weather_data[:humidity_pct],
          pressure_hpa: weather_data[:pressure_hpa],
          observed_at: Time.parse(weather_data[:time]).in_time_zone("Asia/Tokyo"),  # 日本時間で保存
          snapshot: weather_data[:raw]
        )
      end
    end
  end
end