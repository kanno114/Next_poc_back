module Weather
  class Normalizer

    def self.call(forecast:, archive:, current: nil)  # currentパラメータを追加
      current_data = if current && current["current"]
        {
          temperature: current.dig("current", "temperature_2m"),
          humidity:    current.dig("current", "relative_humidity_2m"),
          pressure:    current.dig("current", "surface_pressure"),
          time:        current.dig("current", "time")
        }
      elsif forecast["current"]
        {
          temperature: forecast.dig("current", "temperature_2m"),
          humidity:    forecast.dig("current", "relative_humidity_2m"),
          pressure:    forecast.dig("current", "surface_pressure"),
          time:        forecast.dig("current", "time")
        }
      end

      hourly = []
      if archive && archive["hourly"]
        hourly.concat(zip_hourly(archive["hourly"]))
      end
      if forecast["hourly"]
        hourly.concat(zip_hourly(forecast["hourly"]))
      end

      # 重複時刻をユニーク化（後勝ち）
      map = {}
      hourly.each { |h| map[h[:time]] = h }
      hourly = map.values.sort_by { |h| h[:time] }

      { current: current_data, hourly: }
    end

    def self.zip_hourly(hourly)
      times = hourly["time"] || []
      temps = hourly["temperature_2m"] || []
      hums  = hourly["relative_humidity_2m"] || []
      pres  = hourly["surface_pressure"] || []
      times.map.with_index do |t, i|
        { time: t, temperature: temps[i], humidity: hums[i], pressure: pres[i] }
      end
    end
  end
end
