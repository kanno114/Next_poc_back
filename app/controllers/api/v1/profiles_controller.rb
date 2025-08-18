class Api::V1::ProfilesController < ApplicationController
  before_action :set_user, only: [:show, :update]

  def show
    render json: serializer
  end

  def update
    ActiveRecord::Base.transaction do
      profile = Profile.from_params(profile_params)
      @user.update(profile.to_user_attributes)

      # Locationレコードが存在しない場合は作成
      if @user.location.nil?
        @user.create_location!(profile.to_location_attributes)
      else
        @user.location.update!(profile.to_location_attributes)
      end

      render json: serializer, status: :ok
    end
    rescue => e
      Rails.logger.error "Profile update error: #{e.message}"
      render json: { errors: ["Failed to update profile"] }, status: :unprocessable_entity
    end

  private

  def profile_params
    params.require(:profile).permit(:name, :latitude, :longitude, :user_id)
  end

  def set_user
    # GETリクエストの場合はクエリパラメータから、POST/PUTの場合はプロフィールパラメータからuser_idを取得
    user_id = params[:user_id] || params[:profile]&.dig(:user_id)

    if user_id
      @user = User.find(user_id)
    else
      render json: { errors: ["User ID is required"] }, status: :bad_request
      return
    end
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ["User not found"] }, status: :not_found
  end

  def serializer
    {
      name: @user.name,
      email: @user.email,
      image: @user.image || nil,
      latitude: (@user.location&.latitude).to_f,
      longitude: (@user.location&.longitude).to_f
    }
  end
end