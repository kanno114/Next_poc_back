class PostSerializer
  def initialize(post)
    @post = post
  end

  def as_json
    {
      id: @post.id,
      title: @post.title,
      body: @post.body,
      event_datetime: @post.event_datetime.in_time_zone("Asia/Tokyo").iso8601,  # 日本時間で返却
      created_at: @post.created_at,
      updated_at: @post.updated_at,
      location: location_json,
      weather: weather_json,
      user: user_json,
      tags: tags_json
    }
  end

  private

  def location_json
    return nil unless @post.location

    {
      latitude: @post.location.latitude,
      longitude: @post.location.longitude
    }
  end

  def weather_json
    return nil unless @post.weather_observation

    weather = @post.weather_observation
    {
      temperature_c: weather.temperature_c,
      humidity_pct: weather.humidity_pct,
      pressure_hpa: weather.pressure_hpa,
      observed_at: weather.observed_at.in_time_zone("Asia/Tokyo").iso8601,  # 日本時間で返却
      snapshot: weather.snapshot
    }
  end

  def user_json
    {
      id: @post.user.id,
      name: @post.user.name,
      email: @post.user.email
    }
  end

  def tags_json
    @post.tags.map { |tag| { id: tag.id, name: tag.name } }
  end
end
