class Api::V1::WeathersController < ApplicationController
  def create
    lat = params[:lat].to_f
    lng = params[:lng].to_f

    unless lat.finite? && lng.finite?
      return render json: { error: "invalid coordinates" }, status: :bad_request
    end

    opts = {
      # 過去: 何日分さかのぼるか（archive API）
      past_days:  (params[:past_days]  || 3).to_i,
      # 未来: 何日先まで（forecast API、モデル依存で最大 ~16）
      future_days:(params[:future_days]|| 7).to_i,
      timezone:   (params[:timezone]   || "Asia/Tokyo").to_s
    }

    result = Weather::Fetcher.new(lat:, lng:, **opts).call
    render json: result
  rescue AppError => e
    render json: { error: "upstream error", detail: e.message }, status: :bad_gateway
  rescue => e
    Rails.logger.error("[Weather] Unexpected: #{e.class} #{e.message}")
    render json: { error: "unexpected" }, status: :internal_server_error
  end
end
