class Api::V1::SuggestionsController < ApplicationController
  before_action :set_user

  def index
    date = params[:date].presence&.to_date || Time.zone.today

    begin
      suggestions = Suggestion::SuggestionEngine.call(user: @user, date:)
      render json: suggestions.map { |s| serialize(s) }
    rescue ActiveRecord::RecordNotFound => e
      # DailyLogが見つからない場合
      render json: { error: "指定された日付のログが見つかりません" }, status: :not_found
    rescue => e
      Rails.logger.error("[Suggestions] Error: #{e.class} #{e.message}")
      render json: { error: "提案の取得に失敗しました" }, status: :internal_server_error
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def serialize(s)
    {
      id: s.id,
      title: s.title,
      message: s.message,
      tags: s.tags,
      severity: s.severity,
      triggers: s.triggers
    }
  end
end
