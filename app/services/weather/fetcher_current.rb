module Weather
  class FetcherCurrent
    def initialize(lat:, lng:, timezone: "Asia/Tokyo")
      @lat, @lng = lat, lng
      @timezone = timezone
      @current = Providers::OpenMeteoCurrent.new
    end

    def call
      weather_data = @current.fetch(@lat, @lng, timezone: @timezone)

      # データを正規化
      current = weather_data["current"]
      {
        temperature_c: current["temperature_2m"],
        humidity_pct: current["relative_humidity_2m"],
        pressure_hpa: current["surface_pressure"],
        time: current["time"],
        raw: weather_data
      }
    rescue => e
      Rails.logger.error "Current weather fetch error: #{e.message}"
      raise e
    end
  end
end