# ビジネスロジックや権限チェックなど「Rails標準例外にマッピングしづらいケース」で使う独自の例外
class AppError < StandardError
  attr_reader :status, :code, :details
  def initialize(message = "Error", status: 500, code: "internal.error", details: nil)
    super(message)
    @status  = status
    @code    = code
    @details = details
  end
end
