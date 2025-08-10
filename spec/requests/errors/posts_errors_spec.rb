require "rails_helper"

RSpec.describe "Posts error handling", type: :request do
  let(:base) { "/api/v1/posts" }

  describe "GET /api/v1/posts/:id (404)" do
    it "returns unified 404 json with request_id" do
      get "#{base}/999999"
      expect(response).to have_http_status(:not_found)
      body = json

      expect(body).to include("error")
      expect(body["error"]).to include(
        "code" => "resource.not_found"
      )
      expect(body["error"]["message"]).to be_present
      expect(body["error"]["request_id"]).to be_present
    end
  end

  describe "POST /api/v1/posts (422 RecordInvalid)" do
    it "returns field-level errors in details" do
      # バリデーションに引っかかる入力（例：title/body 必須）
      post base, params: { post: { title: "", body: "" } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      body = json

      expect(body.dig("error", "code")).to eq("validation.failed")
      expect(body.dig("error", "details")).to be_a(Hash)

      # 代表フィールドだけ確認（存在していればOK）
      expect(body.dig("error", "details", "title")).to be_present
      expect(body.dig("error", "details", "body")).to be_present
      expect(body.dig("error", "request_id")).to be_present
    end
  end

  describe "POST /api/v1/posts (422 ParameterMissing)" do
    it "returns param missing error when root key is absent" do
      # root の :post を丸ごと欠落させる
      post base, params: {}, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      body = json

      expect(body.dig("error", "code")).to eq("params.missing")
      expect(body.dig("error", "message")).to be_present
      expect(body.dig("error", "request_id")).to be_present
    end
  end
end
