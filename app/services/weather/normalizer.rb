# app/services/weather/normalizer.rb
module Weather
  class Normalizer
    # Open‑Meteoの current + hourly を共通形へ
    # 戻り値例:
    # {
    #   current: { temperature: 28.1, humidity: 72, pressure: 1005.1, time: "2025-08-13T11:00:00+09:00" },
    #   hourly: [{ time: "2025-08-10T00:00:00+09:00", temperature: ..., humidity: ..., pressure: ... }, ...]
    # }
    def self.call(forecast:, archive:)
      current = if forecast["current"]
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

      { current:, hourly: }
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
