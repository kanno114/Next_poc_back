class Api::V1::RegistrationsController < ApplicationController

  def create
    user = User.new(signup_params)

    if user.save
      render json: { id: user.id, email: user.email, name: user.name }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def oauth_register
    user = User.find_or_initialize_by(email: params[:user][:email])
    user.name = params[:user][:name]
    user.provider = params[:user][:provider] || "oauth"
    user.password ||= SecureRandom.urlsafe_base64(16)

    if user.save
      render json: { status: "ok", id: user.id }
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def signup_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name)
  end
end