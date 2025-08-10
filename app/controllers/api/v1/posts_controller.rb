class Api::V1::PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]

  def index
    @posts = Post.includes(:user, :tags, comments: :user).order(created_at: :desc)
    Rails.logger.info("Posts loaded: #{@posts.count}")
    render json: @posts.map { |post| post_json(post) }, status: :ok
  end

  def show
    render json: post_json(@post), status: :ok
  end

  def create
    @post = Post.create!(post_params)
    render json: post_json(@post), status: :created
  end

  def update
    @post.update!(post_params)
    render json: post_json(@post), status: :ok
  end

  def destroy
    @post.destroy!   # set_post 済み
    render json: { message: 'Post deleted successfully' }, status: :ok
  end

  private

  def set_post
    @post = Post.includes(:user, :tags, comments: :user).find(params[:id])
  end

  # 受信時のパラメータを定義
  def post_params
    params.require(:post).permit(:title, :body, :latitude, :longitude, :user_id, tag_ids: [])
  end

  # 送信時のJSONフォーマットを定義
  def post_json(post)
    {
      id: post.id,
      title: post.title,
      body: post.body,
      longitude: post.longitude,
      latitude: post.latitude,
      created_at: post.created_at,
      updated_at: post.updated_at,
      user: {
        id: post.user.id,
        name: post.user.name,
        email: post.user.email
      },
      tags: post.tags.map { |tag|
        {
          id: tag.id,
          name: tag.name
        }
      },
      comments: post.comments.map { |comment|
        {
          id: comment.id,
          body: comment.body,
          created_at: comment.created_at,
          user: {
            id: comment.user.id,
            name: comment.user.name,
            email: comment.user.email
          }
        }
      }
    }
  end
end
