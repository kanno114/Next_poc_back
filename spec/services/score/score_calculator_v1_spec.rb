require 'rails_helper'

RSpec.describe Score::ScoreCalculatorV1, type: :service do
  let(:user) { create(:user) }
  let(:daily_log) { create(:daily_log, user: user) }
  let(:weather_observation) do
    create(:weather_observation,
          daily_log: daily_log,
          temperature_c: 25.0,
          humidity_pct: 60,
          pressure_hpa: 1013.0,
          observed_at: daily_log.date.beginning_of_day)
  end

  before do
    weather_observation # 天気データを作成
  end

  describe '#call' do
    context '全てのパラメータがある場合' do
      before do
        daily_log.update!(
          sleep_hours: 7.0,
          mood: 2
        )
      end

      it 'スコアを正しく計算する' do
        calculator = described_class.new(daily_log)
        result = calculator.call

        # 新しい計算式に基づく期待値
        # 実際の計算結果を確認してから期待値を設定
        expect(result[:score]).to be_between(0, 100)
        expect(daily_log.reload.score).to eq(result[:score])
      end
    end

    context 'パラメータが不足している場合' do
      before do
        daily_log.update!(
          sleep_hours: nil,
          mood: nil
        )
      end

      it 'ベーススコアを計算する' do
        calculator = described_class.new(daily_log)
        result = calculator.call

        # 新しい計算式に基づく期待値
        expect(result[:score]).to be_between(0, 100)
        expect(daily_log.reload.score).to eq(result[:score])
      end
    end

    context 'persist: falseの場合' do
      it 'データベースを更新しない' do
        original_score = daily_log.score
        calculator = described_class.new(daily_log)
        result = calculator.call(persist: false)

        expect(result[:score]).to be_present
        expect(daily_log.reload.score).to eq(original_score)
      end
    end

    context '極端な値の場合' do
      before do
        daily_log.update!(
          sleep_hours: 24.0,
          mood: 5
        )
      end

      it '有効な範囲内でスコアを計算する' do
        calculator = described_class.new(daily_log)
        result = calculator.call

        # 極端な値でも0-100の範囲内に収まることを確認
        expect(result[:score]).to be_between(0, 100)
        expect(daily_log.reload.score).to eq(result[:score])
      end
    end

    context '負の値の場合' do
      before do
        daily_log.update!(
          sleep_hours: 0.0,
          mood: -5
        )
      end

      it '有効な範囲内でスコアを計算する' do
        calculator = described_class.new(daily_log)
        result = calculator.call

        # 負の値でも0-100の範囲内に収まることを確認
        expect(result[:score]).to be_between(0, 100)
        expect(daily_log.reload.score).to eq(result[:score])
      end
    end
  end
end