require "digest/md5"
require "net/http"

module Weather
  class FetcherOnDate
    TTL = 10.minutes

    def initialize(lat:, lng:, date:, timezone:)
      @lat, @lng = lat, lng
      @date = date.to_date
      @timezone = timezone
      @archive = Providers::OpenMeteoArchive.new
    end

    def call
      key = cache_key
      Rails.cache.fetch(key, expires_in: TTL) do
        fetch_weather_data
      end
    end

    private

    def fetch_weather_data
      # 指定日付のデータを取得
      archive_data = with_retry { @archive.fetch(@lat, @lng, past_days: 1, timezone: @timezone) }
      
      if archive_data && archive_data["hourly"]
        # 指定日付のデータを抽出
        target_data = extract_data_for_date(archive_data["hourly"], @date)
        
        if target_data && target_data[:temperature]  # nilチェックを追加
          {
            temperature_c: target_data[:temperature],
            humidity_pct: target_data[:humidity],
            pressure_hpa: target_data[:pressure],
            time: target_data[:time],
            raw: archive_data
          }
        else
          # データが見つからない、またはnilの場合は現在の天気を取得
          fetch_current_weather
        end
      else
        # アーカイブデータが取得できない場合は現在の天気を取得
        fetch_current_weather
      end
    end

    def extract_data_for_date(hourly_data, target_date)
      times = hourly_data["time"] || []
      temps = hourly_data["temperature_2m"] || []
      hums = hourly_data["relative_humidity_2m"] || []
      pres = hourly_data["surface_pressure"] || []

      # 指定日付のデータを全て収集（nilでないもののみ）
      candidates = []
      times.each_with_index do |time_str, index|
        time = Time.parse(time_str)
        if time.in_time_zone(@timezone).to_date == target_date && temps[index]
          candidates << {
            time: time_str,
            parsed_time: time,
            temperature: temps[index],
            humidity: hums[index],
            pressure: pres[index],
            index: index
          }
        end
      end

      return nil if candidates.empty?

      # 指定日付の目標時刻を設定
      target_time = @date.to_time.in_time_zone(@timezone)

      # 最も近い時刻のデータを選択
      closest_candidate = candidates.min_by do |candidate|
        (candidate[:parsed_time] - target_time).abs
      end

      {
        time: closest_candidate[:time],
        temperature: closest_candidate[:temperature],
        humidity: closest_candidate[:humidity],
        pressure: closest_candidate[:pressure]
      }
    end

    def fetch_current_weather
      current = Providers::OpenMeteoCurrent.new
      current_data = with_retry { current.fetch(@lat, @lng, timezone: @timezone) }

      if current_data && current_data["current"]
        current = current_data["current"]
        {
          temperature_c: current["temperature_2m"],
          humidity_pct: current["relative_humidity_2m"],
          pressure_hpa: current["surface_pressure"],
          time: current["time"],
          raw: current_data
        }
      else
        raise AppError.new(
          "Weather data not available",
          status: 503,
          code: "weather.data_unavailable"
        )
      end
    end

    def cache_key
      digest = Digest::MD5.hexdigest([@lat.round(3), @lng.round(3), @date.to_s, @timezone].join(":"))
      "weather:date:v1:#{digest}"
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
