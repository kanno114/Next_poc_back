require 'rails_helper'

RSpec.describe "Api::V1::DailyLogsForm", type: :request do
  let(:user) { create(:user) }
  let(:location) { create(:location, user: user) }
  let(:valid_params) do
    {
      daily_log: {
        date: '2025-08-20',
        score: 80,
        sleep_hours: 7,
        mood: 2,
        memo: '今日は良い天気でした',
        user_id: user.id
      }
    }
  end

  before do
    location # ユーザーにロケーションを作成
  end

  describe 'POST /api/v1/daily_logs' do
    context '有効なパラメータの場合' do
      it '新しいデイリーログを作成する' do
        expect {
          post '/api/v1/daily_logs', params: valid_params, as: :json
        }.to change(DailyLog, :count).by(1)

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['date']).to eq('2025-08-20')
        expect(json_response['score']).to eq(80)
        expect(json_response['sleep_hours']).to eq('7.0')
        expect(json_response['mood']).to eq(2)
        expect(json_response['memo']).to eq('今日は良い天気でした')
      end

      it '天気観測データを作成する' do
        expect {
          post '/api/v1/daily_logs', params: valid_params, as: :json
        }.to change(WeatherObservation, :count).by(1)
      end

      it 'RecalcDailyScoreJobをエンキューする' do
        expect {
          post '/api/v1/daily_logs', params: valid_params, as: :json
        }.to have_enqueued_job(RecalcDailyScoreJob)
      end
    end

    context '無効なパラメータの場合' do
      let(:invalid_params) do
        {
          daily_log: {
            date: '2025-08-20',
            score: 150, # 無効なスコア
            sleep_hours: 7,
            mood: 2,
            memo: '今日は良い天気でした',
            user_id: user.id
          }
        }
      end

      it 'unprocessable entityステータスを返す' do
        post '/api/v1/daily_logs', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Score must be less than or equal to 100')
      end
    end

    context '数値以外の気分の場合' do
      let(:string_mood_params) do
        {
          daily_log: {
            date: '2025-08-20',
            score: 80,
            sleep_hours: 7,
            mood: '良い', # 文字列
            memo: '今日は良い天気でした',
            user_id: user.id
          }
        }
      end

      it '文字列の気分を整数に変換する' do
        post '/api/v1/daily_logs', params: string_mood_params, as: :json

        expect(response).to have_http_status(:created)
        
        json_response = JSON.parse(response.body)
        expect(json_response['mood']).to eq(0) # "良い".to_i = 0
      end
    end
  end

  describe 'PUT /api/v1/daily_logs/:id' do
    let(:daily_log) { create(:daily_log, user: user) }

    context '有効なパラメータの場合' do
      it 'デイリーログを更新する' do
        put "/api/v1/daily_logs/#{daily_log.id}", params: valid_params, as: :json

        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['score']).to eq(80)
        expect(json_response['mood']).to eq(2)
        expect(json_response['memo']).to eq('今日は良い天気でした')
      end

      it 'RecalcDailyScoreJobをエンキューする' do
        expect {
          put "/api/v1/daily_logs/#{daily_log.id}", params: valid_params, as: :json
        }.to have_enqueued_job(RecalcDailyScoreJob)
      end
    end

    context '無効なパラメータの場合' do
      let(:invalid_params) do
        {
          daily_log: {
            date: '2025-08-20',
            score: 150, # 無効なスコア
            sleep_hours: 7,
            mood: 2,
            memo: '今日は良い天気でした',
            user_id: user.id
          }
        }
      end

      it 'unprocessable entityステータスを返す' do
        put "/api/v1/daily_logs/#{daily_log.id}", params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Score must be less than or equal to 100')
      end
    end
  end
end
