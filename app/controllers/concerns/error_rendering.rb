module ErrorRendering
  extend ActiveSupport::Concern

  included do
    # Rails は 下にある宣言ほど優先してマッチするため、汎用を先に記述
    rescue_from StandardError,                     with: :render_internal_error
    # ビジネスロジックや権限チェックなど「Rails標準例外にマッピングしづらいケース」で使う独自の例外
    rescue_from AppError,                          with: :render_app_error
    # Rails 標準の例外を個別にハンドリング
    rescue_from ActiveRecord::RecordNotFound,      with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid,       with: :render_record_invalid
    rescue_from ActionController::ParameterMissing,with: :render_param_missing
  end

  private

  def render_app_error(e)
    render_error(e.code, e.message, e.status, details: e.details)
  end

  def render_not_found(e)
    render_error("resource.not_found", e.message, 404)
  end

  def render_record_invalid(e)
    render_error("validation.failed", e.record.errors.full_messages, 422, details: e.record.errors.to_hash)
  end

  def render_param_missing(e)
    render_error("params.missing", e.message, 422)
  end

  def render_internal_error(e)
    render_error("internal.error",
      Rails.env.production? ? "サーバでエラーが発生しました" : e.message,
      500
    )
  end

  def render_error(code, message, status, details: nil)
    render json: {
      error: {
        code: code,
        message: message,
        details: details,
        request_id: request.request_id
      }
    }, status: status
  end
end
