class Api::V1::SessionsController < ApplicationController

  def create
    user = User.find_by(email: params[:user][:email])

    if user&.authenticate(params[:user][:password])
      render json: { id: user.id, email: user.email, name: user.name }, status: :ok
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end
end