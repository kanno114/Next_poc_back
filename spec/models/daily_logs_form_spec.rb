require 'rails_helper'

RSpec.describe DailyLogsForm, type: :model do
  describe 'バリデーション' do
    subject do
      described_class.new(
        date: Date.current,
        score: 80,
        sleep_hours: 7,
        mood: 2,
        memo: '今日は良い天気でした'
      )
    end

    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:score) }
    it { should validate_presence_of(:sleep_hours) }
    it { should validate_presence_of(:mood) }
    it { should validate_presence_of(:memo) }

    # 数値バリデーションは手動でテスト
    describe 'スコアのバリデーション' do
      it 'スコアが0から100の間であることを検証する' do
        form = described_class.new(score: -1)
        expect(form).not_to be_valid
        expect(form.errors[:score]).to include('must be greater than or equal to 0')

        form = described_class.new(score: 101)
        expect(form).not_to be_valid
        expect(form.errors[:score]).to include('must be less than or equal to 100')
      end
    end

    describe '睡眠時間のバリデーション' do
      it '睡眠時間が0から24の間であることを検証する' do
        form = described_class.new(sleep_hours: -1)
        expect(form).not_to be_valid
        expect(form.errors[:sleep_hours]).to include('must be greater than or equal to 0')

        form = described_class.new(sleep_hours: 25)
        expect(form).not_to be_valid
        expect(form.errors[:sleep_hours]).to include('must be less than or equal to 24')
      end
    end

    describe '気分のバリデーション' do
      it '気分が-5から5の間であることを検証する' do
        form = described_class.new(mood: -6)
        expect(form).not_to be_valid
        expect(form.errors[:mood]).to include('must be greater than or equal to -5')

        form = described_class.new(mood: 6)
        expect(form).not_to be_valid
        expect(form.errors[:mood]).to include('must be less than or equal to 5')
      end
    end
  end

  describe '.from_params' do
    let(:params) do
      {
        date: '2025-08-20',
        score: '80',
        sleep_hours: '7',
        mood: '2',
        memo: '今日は良い天気でした'
      }
    end

    it '正しい属性でフォームを作成する' do
      form = described_class.from_params(params)

      expect(form.date).to eq(Date.parse('2025-08-20'))
      expect(form.score).to eq(80)
      expect(form.sleep_hours).to eq(7)
      expect(form.mood).to eq(2)
      expect(form.memo).to eq('今日は良い天気でした')
    end

    it '文字列値を正しく処理する' do
      form = described_class.from_params(params)

      expect(form.score.class).to eq(Integer)
      expect(form.sleep_hours.class).to eq(Integer)
      expect(form.mood.class).to eq(Integer)
      expect(form.memo.class).to eq(String)
    end
  end

  describe '#to_daily_log_attributes' do
    let(:form) do
      described_class.new(
        date: Date.parse('2025-08-20'),
        score: 80,
        sleep_hours: 7,
        mood: 2,
        memo: '今日は良い天気でした'
      )
    end

    it '正しい属性ハッシュを返す' do
      attributes = form.to_daily_log_attributes

      expect(attributes).to eq({
        date: Date.parse('2025-08-20'),
        score: 80,
        sleep_hours: 7,
        mood: 2,
        memo: '今日は良い天気でした'
      })
    end
  end
end
