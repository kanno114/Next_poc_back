require 'net/http'

module Weather
  module Providers
    class OpenMeteoCurrent
      BASE = "https://api.open-meteo.com/v1/forecast"

      def key; "openmeteo-current"; end

      def fetch(lat, lng, timezone: "Asia/Tokyo")
        uri = URI(BASE)
        params = {
          latitude: lat, longitude: lng,
          current: "temperature_2m,relative_humidity_2m,surface_pressure",
          timezone:, temperature_unit: "celsius", pressure_unit: "hPa"
        }
        uri.query = URI.encode_www_form(params)

        res = Net::HTTP.get_response(uri)
        Rails.logger.info("[Weather] OpenMeteoCurrent #{uri} #{res.code}")
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
