# app/services/weather/fetcher.rb
require "digest/md5"

module Weather
  class Fetcher
    TTL = 10.minutes

    def initialize(lat:, lng:, past_days:, future_days:, timezone:)
      @lat, @lng = lat, lng
      @past_days, @future_days, @timezone = past_days, future_days, timezone
      @forecast = Providers::OpenMeteoForecast.new
      @archive  = Providers::OpenMeteoArchive.new
    end

    def call
      key = cache_key
      Rails.cache.fetch(key, expires_in: TTL) do
        f = with_retry { @forecast.fetch(@lat, @lng, future_days: @future_days, timezone: @timezone) }
        a = with_retry { @archive.fetch(@lat, @lng, past_days: @past_days, timezone: @timezone) } if @past_days.to_i > 0
        Weather::Normalizer.call(forecast: f, archive: a)
      end
    end

    private

    def cache_key
      digest = Digest::MD5.hexdigest([@lat.round(3), @lng.round(3), @past_days, @future_days, @timezone].join(":"))
      "weather:v1:#{digest}"
    end

    def with_retry(max: 3)
      attempts = 0
      begin
        attempts += 1
        yield
      rescue => e
        raise e if attempts >= max
        sleep(0.4 * attempts)
        retry
      end
    end
  end
end
