class Api::V1::PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]

  def index
    @posts = Post.includes(:user, :tags, comments: :user).order(created_at: :desc)
    render json: @posts.map { |post| post_json(post) }, status: :ok
  end

  def show
    render json: post_json(@post), status: :ok
  end

  def create
    @post = Post.new(post_params)

    # 天気付与
    if valid_coords?(@post.latitude, @post.longitude)
      if (w = Weather::CurrentFetcher.call(lat: @post.latitude, lng: @post.longitude))
        @post.temperature_c       = w[:temperature_c]
        @post.humidity_pct        = w[:humidity_pct]
        @post.pressure_hpa        = w[:pressure_hpa]
        @post.weather_observed_at = w[:time] ? Time.zone.parse(w[:time]) : Time.zone.now
        @post.weather_snapshot    = w[:raw]
      end
    end

    @post.save!
    render json: post_json(@post), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: @post.errors.full_messages.presence || [e.message] }, status: :unprocessable_entity
  end

  def update
    @post.update!(post_params)
    render json: post_json(@post), status: :ok
  end

  def destroy
    @post.destroy!
    render json: { message: 'Post deleted successfully' }, status: :ok
  end

  private

  def set_post
    @post = Post.includes(:user, :tags, comments: :user).find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :latitude, :longitude, :user_id, tag_ids: [])
  end

  def valid_coords?(lat, lng)
    lat.is_a?(Numeric) && lng.is_a?(Numeric) && lat.finite? && lng.finite? &&
      lat.between?(-90, 90) && lng.between?(-180, 180)
  end

  def post_json(post)
    {
      id: post.id,
      title: post.title,
      body: post.body,
      longitude: post.longitude,
      latitude: post.latitude,
      created_at: post.created_at,
      updated_at: post.updated_at,
      weather: {
        temperature_c: post.temperature_c,
        humidity_pct:  post.humidity_pct,
        pressure_hpa:  post.pressure_hpa,
        observed_at:   post.weather_observed_at
      },
      user: {
        id: post.user.id,
        name: post.user.name,
        email: post.user.email
      },
      tags: post.tags.map { |tag| { id: tag.id, name: tag.name } },
      comments: post.comments.map { |comment|
        {
          id: comment.id,
          body: comment.body,
          created_at: comment.created_at,
          user: { id: comment.user.id, name: comment.user.name, email: comment.user.email }
        }
      }
    }
  end
end
