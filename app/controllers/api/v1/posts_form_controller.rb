require_relative '../../../serializers/post_serializer'

class Api::V1::PostsFormController < ApplicationController
  before_action :set_post, only: [:update]

  def create
    ActiveRecord::Base.transaction do
      # ユーザーの取得
      user = User.find(post_params[:user_id])
      # event_datetimeを日本時間として処理
      event_datetime = Time.parse(post_params[:event_datetime]).in_time_zone("Asia/Tokyo")
      # 投稿の作成
      post = Post.create!(
        title: post_params[:title],
        body: post_params[:body],
        user: user,
        event_datetime: event_datetime  # 日本時間で保存
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

        @post.update!(@post_form.to_post_attributes)

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
    @post = Post.includes(:user, :tags)
                .find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :event_datetime, :user_id)
  end
end
