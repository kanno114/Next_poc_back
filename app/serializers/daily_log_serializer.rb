class DailyLogSerializer
  def initialize(daily_log)
    @daily_log = daily_log
  end

  def as_json
    {
      id: @daily_log.id,
      date: @daily_log.date,
      score: @daily_log.score,
      sleep_hours: @daily_log.sleep_hours,
      mood: @daily_log.mood,
      memo: @daily_log.memo,
      created_at: @daily_log.created_at,
      updated_at: @daily_log.updated_at,
      formatted_date: @daily_log.date.strftime('%Y-%m-%d'),
      user: user_json,
      weather: weather_json,
    }
  end

  private

  def user_json
    {
      id: @daily_log.user.id,
      name: @daily_log.user.name,
      email: @daily_log.user.email
    }
  end

  def weather_json
    return nil unless @daily_log.weather_observation

    weather = @daily_log.weather_observation
    {
      temperature_c: weather.temperature_c,
      humidity_pct: weather.humidity_pct,
      pressure_hpa: weather.pressure_hpa,
      observed_at: weather.observed_at.iso8601,
      snapshot: weather.snapshot
    }
  end
end
