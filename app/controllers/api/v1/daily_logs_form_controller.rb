class Api::V1::DailyLogsFormController < ApplicationController
  before_action :set_daily_log, only: [:update]
  after_action :recalc_score, only: [:create, :update]

# test
# curl -X POST http://localhost:3001/api/v1/daily_logs -H "Content-Type: application/json" -d '{"daily_log":{"date":"2025-08-20","score":80,"sleep_hours":7,"mood":5,"memo":"今日は良い天気でした","user_id":1}}'

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

  # test
  # curl -X PUT http://localhost:3001/api/v1/daily_logs/1 -H "Content-Type: application/json" -d '{"daily_log":{"date":"2025-08-20","score":80,"sleep_hours":7,"mood":5,"memo":"今日は良い天気でした","user_id":1}}'
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
    params.require(:daily_log).permit(:id, :date, :score, :sleep_hours, :mood, :memo, :user_id)
  end

  def recalc_score
    RecalcDailyScoreJob.perform_later(@daily_log.id, )
  end
end
