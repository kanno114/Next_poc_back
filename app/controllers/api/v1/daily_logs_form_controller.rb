class Api::V1::DailyLogsFormController < ApplicationController
  before_action :set_daily_log, only: [:update]

  def create
    user = User.find(daily_log_params[:user_id])

    @daily_log_form = DailyLogsForm.from_params(daily_log_params)

    @daily_log = DailyLog.new(@daily_log_form.to_daily_log_attributes)
    @daily_log.user = user

    if @daily_log.save
      Weather::WeatherService.create_or_update_weather_observation(
        daily_log: @daily_log,
        lat: user.location.latitude,
        lng: user.location.longitude
      )
      render json: DailyLogSerializer.new(@daily_log).as_json, status: :created
    else
      render json: { errors: @daily_log.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @daily_log_form = DailyLogsForm.from_params(daily_log_params)
    @daily_log = DailyLog.find(params[:id])

    if @daily_log.update(@daily_log_form.to_daily_log_attributes)
      render json: DailyLogSerializer.new(@daily_log).as_json, status: :ok
    else
      render json: { errors: @daily_log.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_daily_log
    @daily_log = DailyLog.includes(:user, :weather_observation)
                        .find(params[:id])
  end

  def daily_log_params
    params.require(:daily_log).permit(:id,:date, :score, :sleep_hours, :mood, :memo, :user_id)
  end
end
