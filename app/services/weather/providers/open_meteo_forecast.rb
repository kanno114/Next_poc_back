require 'net/http'

module Weather
  module Providers
    class OpenMeteoForecast
      BASE = "https://api.open-meteo.com/v1/forecast"

      def key; "openmeteo-forecast"; end

      def fetch(lat, lng, timezone: "Asia/Tokyo", future_days:)
        uri = URI(BASE)
        params = {
          latitude: lat, longitude: lng,
          current: "temperature_2m,relative_humidity_2m,surface_pressure",
          hourly:  "temperature_2m,relative_humidity_2m,surface_pressure",
          timezone:, temperature_unit: "celsius", pressure_unit: "hPa"
        }
        # future_days は hourly/dailyの期間に影響（Open‑Meteoは過去も少し含むことがある）
        # 明示的に先の上限を狙うなら "forecast_days" を daily で使うが hourly はモデル次第
        uri.query = URI.encode_www_form(params)

        res = Net::HTTP.get_response(uri)
        Rails.logger.info("[Weather] OpenMeteoForecast #{uri} #{res.code}")
        unless res.is_a?(Net::HTTPSuccess)
          raise AppError.new(
            "Upstream weather API error",
            status: 502,
            code:   "weather.upstream_error",
            details: { provider: key, http_status: res.code, body: res.body }
          )
        end
        JSON.parse(res.body)
      end
    end
  end
end
