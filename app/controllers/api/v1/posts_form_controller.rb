require_relative '../../../serializers/post_serializer'
require_relative '../../../services/weather/weather_service'

class Api::V1::PostsFormController < ApplicationController
  before_action :set_post, only: [:update]

  def create
    ActiveRecord::Base.transaction do
      # 位置情報の処理
      location = Location.find_or_create_by!(
        latitude: post_params[:location][:latitude].round(6),
        longitude: post_params[:location][:longitude].round(6)
      )

      # ユーザーの取得
      user = User.find(post_params[:user_id])

      # event_datetimeを日本時間として処理
      event_datetime = Time.parse(post_params[:event_datetime]).in_time_zone("Asia/Tokyo")

      # 投稿の作成
      post = Post.create!(
        title: post_params[:title],
        body: post_params[:body],
        user: user,
        location: location,
        event_datetime: event_datetime  # 日本時間で保存
      )

      # 天気データの取得・保存
      WeatherService.create_or_update_weather_observation(
        post: post,
        lat: post_params[:location][:latitude],
        lng: post_params[:location][:longitude],
        event_datetime: post.event_datetime
      )

      render json: PostSerializer.new(post).as_json, status: :created
    end
  rescue => e
    Rails.logger.error "Post creation error: #{e.message}"
    render json: { error: "Post creation failed" }, status: :unprocessable_entity
  end

  def update
    @post_form = PostForm.from_params(post_params)

    if @post_form.valid?
      ActiveRecord::Base.transaction do
        # 位置情報の更新処理
        location_changed = false
        if @post_form.latitude.present? && @post_form.longitude.present?
          location_changed = update_location
        end

        @post.update!(@post_form.to_post_attributes)

        # 座標と日時が変更された場合、天気データを更新
        if (location_changed || @post.event_datetime.to_date != @post_form.event_datetime.to_date)
          WeatherService.create_or_update_weather_observation(
            post: @post,
            lat: @post_form.latitude,
            lng: @post_form.longitude,
            event_datetime: @post.event_datetime
          )
        end

        render json: PostSerializer.new(@post).as_json, status: :ok
      end
    else
      render json: { errors: @post_form.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: @post.errors.full_messages.presence || [e.message] }, status: :unprocessable_entity
  end

  private

  def set_post
    @post = Post.includes(:user, :tags, :location, :weather_observation)
                .find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :event_datetime, :user_id, location: [:latitude, :longitude])
  end

  def update_location
    if @post.location
      old_lat = @post.location.latitude
      old_lng = @post.location.longitude

      @post.location.update!(@post_form.to_location_attributes)

      # 場所が実際に変更されたかどうかを確認
      new_lat = @post.location.reload.latitude
      new_lng = @post.location.reload.longitude

      old_lat.to_f != new_lat.to_f || old_lng.to_f != new_lng.to_f
    else
      location = Location.create!(@post_form.to_location_attributes)
      @post.update!(location: location)
      true # 新しく場所が設定された
    end
  end
end
