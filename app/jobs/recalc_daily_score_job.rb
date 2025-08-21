# app/jobs/recalc_daily_score_job.rb
class RecalcDailyScoreJob < ApplicationJob
  queue_as :default

  def perform(daily_log_id)
    log = DailyLog.find(daily_log_id)
    Score::ScoreCalculatorV1.new(log).call(persist: true)
  end
end
