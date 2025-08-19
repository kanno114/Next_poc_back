class Api::V1::DailyLogsController < ApplicationController
  before_action :set_current_user, only: [:index, :by_date_range]
  before_action :set_daily_log, only: [:show, :destroy]

  def index
    @daily_logs = DailyLog.includes(:user, :weather_observation)
                          .where(user: @current_user)
                          .order(date: :desc)
    render json: @daily_logs.map { |daily_log| DailyLogSerializer.new(daily_log).as_json }, status: :ok
  end

  def show
    render json: DailyLogSerializer.new(@daily_log).as_json, status: :ok
  end

  def destroy
    @daily_log.destroy!
    render json: { message: 'Daily log deleted successfully' }, status: :ok
  end

  def by_date_range
    start_date = params[:start_date]&.to_date
    end_date = params[:end_date]&.to_date

    if start_date && end_date
      @daily_logs = DailyLog.includes(:user, :weather_observation)
                            .where(user: current_user)
                            .by_date_range(start_date, end_date)
                            .order(date: :desc)
      render json: @daily_logs.map { |daily_log| DailyLogSerializer.new(daily_log).as_json }, status: :ok
    else
      render json: { error: 'start_date and end_date are required' }, status: :bad_request
    end
  end

  private

  def set_daily_log
    @daily_log = DailyLog.includes(:user, :weather_observation)
                        .find(params[:id])
  end

  def daily_log_params
    params.require(:daily_log).permit(:date, :score, :sleep_hours, :mood, :memo, :weather_observation_id)
  end

  def set_current_user
    @current_user = User.find(params[:user_id])
  end
end
