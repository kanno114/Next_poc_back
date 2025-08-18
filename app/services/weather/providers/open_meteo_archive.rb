require 'net/http'

module Weather
  module Providers
    class OpenMeteoArchive
      BASE = "https://archive-api.open-meteo.com/v1/archive"

      def key; "openmeteo-archive"; end

      def fetch(lat, lng, timezone: "Asia/Tokyo", past_days:)
        return nil if past_days <= 0
        end_date   = Date.today - 1
        start_date = end_date - (past_days - 1)

        uri = URI(BASE)
        params = {
          latitude: lat, longitude: lng,
          start_date:, end_date:,
          hourly: "temperature_2m,relative_humidity_2m,surface_pressure",
          timezone:, temperature_unit: "celsius", pressure_unit: "hPa"
        }
        uri.query = URI.encode_www_form(params)

        res = Net::HTTP.get_response(uri)
        raise Weather::Errors::UpstreamError, "archive #{res.code}" unless res.is_a?(Net::HTTPSuccess)
        JSON.parse(res.body)
      end
    end
  end
end