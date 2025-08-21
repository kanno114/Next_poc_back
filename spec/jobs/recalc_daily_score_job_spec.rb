require 'rails_helper'

RSpec.describe RecalcDailyScoreJob, type: :job do
  let(:daily_log) { create(:daily_log) }

  describe '#perform' do
    it 'ScoreCalculatorV1を呼び出す' do
      calculator_double = instance_double(Score::ScoreCalculatorV1)
      allow(Score::ScoreCalculatorV1).to receive(:new).with(daily_log).and_return(calculator_double)
      allow(calculator_double).to receive(:call).with(persist: true)

      described_class.perform_now(daily_log.id)

      expect(Score::ScoreCalculatorV1).to have_received(:new).with(daily_log)
      expect(calculator_double).to have_received(:call).with(persist: true)
    end

    it '存在しないデイリーログを適切に処理する' do
      expect {
        described_class.perform_now(99999)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'ジョブのエンキュー' do
    it 'エンキューできる' do
      expect {
        described_class.perform_later(daily_log.id)
      }.to have_enqueued_job(described_class).with(daily_log.id)
    end
  end
end
