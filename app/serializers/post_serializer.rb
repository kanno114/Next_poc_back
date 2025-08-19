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
      user: user_json,
      tags: tags_json
    }
  end

  private

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
