# app/services/weather/current_fetcher.rb
require "net/http"
require "json"

module Weather
  class CurrentFetcher
    BASE_URL = "https://api.open-meteo.com/v1/forecast".freeze

    # 戻り値: { temperature_c:, humidity_pct:, pressure_hpa:, time:, raw: {...} } or nil
    def self.call(lat:, lng:, timezone: "Asia/Tokyo", open_timeout: 2, read_timeout: 3)
      uri = URI(BASE_URL)
      params = {
        latitude: lat,
        longitude: lng,
        current: "temperature_2m,relative_humidity_2m,surface_pressure",
        timezone: timezone,
        temperature_unit: "celsius",
        pressure_unit: "hPa"
      }
      uri.query = URI.encode_www_form(params)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = open_timeout
      http.read_timeout = read_timeout

      res = http.get(uri.request_uri, { "Accept" => "application/json" })
      return nil unless res.is_a?(Net::HTTPSuccess)

      data = JSON.parse(res.body)
      current = data["current"] || {}
      {
        temperature_c: current["temperature_2m"],
        humidity_pct:  current["relative_humidity_2m"],
        pressure_hpa:  current["surface_pressure"],
        time:          current["time"],
        raw:           data
      }
    rescue => e
      Rails.logger.warn("[Weather::CurrentFetcher] Failed: #{e.class} #{e.message}")
      nil
    end
  end
end
