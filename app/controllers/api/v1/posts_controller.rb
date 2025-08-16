require_relative '../../../serializers/post_serializer'

class Api::V1::PostsController < ApplicationController
  before_action :set_post, only: [:show, :destroy]

  def index
    @posts = Post.includes(:user, :tags, :location, :weather_observation).order(created_at: :desc)
    render json: @posts.map { |post| PostSerializer.new(post).as_json }, status: :ok
  end

  def show
    render json: PostSerializer.new(@post).as_json, status: :ok
  end

  def destroy
    @post.destroy!
    render json: { message: 'Post deleted successfully' }, status: :ok
  end

  private

  def set_post
    @post = Post.includes(:user, :tags, :location, :weather_observation)
                .find(params[:id])
  end
end
