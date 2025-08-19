require 'bcrypt'

puts "🌱 Seeding started..."

# 初期化（順番に注意）
User.destroy_all
Tag.destroy_all
WeatherObservation.destroy_all
DailyLog.destroy_all
Location.destroy_all
Post.destroy_all
PostTag.destroy_all

# タグ作成
tag_names = %w[テスト サンプル Rails React Ruby 旅行 グルメ 観光 自然 文化 歴史 アート スポーツ 温泉 夜景 神社 寺 公園 博物館 美術館 レストラン カフェ ショッピング 季節]
tags = tag_names.map { |name| Tag.find_or_create_by!(name: name) }

puts "✅ Created #{tags.count} tags."

# 首都圏内の緯度・経度の範囲（東京、神奈川、埼玉、千葉）
CAPITAL_AREA_LAT_RANGE = (35.4..36.2) # 緯度（首都圏）
CAPITAL_AREA_LNG_RANGE = (139.2..140.2) # 経度（首都圏）

# 投稿データのテンプレート
post_templates = [
  {
    title: "素晴らしい景色でした！",
    body: "今日は天気も良くて、本当に美しい景色を楽しめました。写真を撮るのに最適な時間帯でした。"
  },
  {
    title: "地元の美味しいお店を発見",
    body: "偶然見つけた小さなレストランですが、料理が本当に美味しかったです。また来たいと思います。"
  },
  {
    title: "歴史的な建物を訪れて",
    body: "長い歴史を持つこの建物は、実際に見ると迫力が違いました。ガイドさんの説明もとても興味深かったです。"
  },
  {
    title: "自然の中でのんびり",
    body: "都会の喧騒を離れて、自然の中でゆっくりとした時間を過ごしました。心が癒されました。"
  },
  {
    title: "季節の花が綺麗でした",
    body: "ちょうど見頃の花々が咲いていて、とても美しかったです。多くの人が写真を撮っていました。"
  },
  {
    title: "夜景が絶景でした",
    body: "夜の街並みがとても美しく、特に夜景スポットからの眺めは格別でした。"
  },
  {
    title: "温泉で疲れを癒して",
    body: "久しぶりに温泉に入って、疲れがすっかり取れました。露天風呂からの景色も良かったです。"
  },
  {
    title: "美術館で芸術に触れて",
    body: "素晴らしい作品がたくさん展示されていて、時間を忘れて見入ってしまいました。"
  },
  {
    title: "地元の祭りに参加",
    body: "伝統的な祭りに参加できて、とても貴重な体験ができました。地域の文化を感じられました。"
  },
  {
    title: "カフェで一息",
    body: "おしゃれなカフェで美味しいコーヒーを飲みながら、ゆっくりとした時間を過ごしました。"
  }
]

# ユーザー作成（位置情報付き）
puts "👥 Creating users with locations..."

users = []
8.times do |i|
  # ユーザーを先に作成
  user = User.create!(
    email: "testuser#{i + 1}@example.com",
    name: "テストユーザー#{i + 1}",
    password_digest: BCrypt::Password.create("testtest")
  )

  # 首都圏内のランダムな位置を生成
  latitude = rand(CAPITAL_AREA_LAT_RANGE)
  longitude = rand(CAPITAL_AREA_LNG_RANGE)

  # 位置情報を作成し、ユーザーに関連付け
  Location.create!(
    user: user,
    latitude: latitude,
    longitude: longitude
  )

  users << user
end

puts "✅ Created #{users.count} users with locations."

# 投稿 + 天気観測データ + タグ付け
puts "📝 Creating posts with weather data and tags..."

users.each_with_index do |user, idx|
  15.times do |i| # 各ユーザーに15件ずつ投稿を作成（合計120件）

    # 投稿テンプレートからランダム選択
    template = post_templates.sample

    # イベント日時を過去1ヶ月以内のランダムな日付に設定
    event_datetime = Date.current - rand(0..30)

    post = Post.create!(
      title: template[:title],
      body: template[:body],
      user: user,
      event_datetime: event_datetime
    )

    # ランダムに1-3個のタグを付与
    post.tags << tags.sample(rand(1..3))
  end
end

# DailyLogデータの作成（天気情報と位置情報付き）
puts "📝 Creating daily logs with weather and location data..."

users.each do |user|
  # 過去30日間のdaily_logを作成
  30.times do |i|
    log_date = Date.current - i

    # 気分とスコアの相関関係を作成
    mood = rand(-2..5)
    mood = [mood, 5].min # 最大5に制限

    # スコアは気分と睡眠時間に基づいて決定
    sleep_hours = rand(5.0..9.0).round(1)
    base_score = (mood + 2) * 10 + (sleep_hours - 5) * 5
    score = [[base_score, 100].min, 0].max # 0-100の範囲に制限

    # メモのテンプレート
    memo_templates = [
      "睡眠時間は#{sleep_hours}時間でした。",
      "気分は#{mood > 0 ? "良い" : mood < 0 ? "悪い" : "普通"}です。",
      "今日も頑張りました。",
      "新しい発見がありました。",
      "リラックスできた一日でした。",
      "充実した時間を過ごせました。"
    ]

    memo = memo_templates.sample(rand(1..3)).join(" ")

    # DailyLogを先に作成
    daily_log = DailyLog.create!(
      user: user,
      date: log_date,
      score: score,
      sleep_hours: sleep_hours,
      mood: mood,
      memo: memo
    )

    # 天気観測データを作成
    weather_condition = %w[晴れ 曇り 雨 雪].sample
    weather_observation = WeatherObservation.create!(
      daily_log: daily_log,
      temperature_c: rand(-5.0..35.0).round(1),
      humidity_pct: rand(30..90),
      pressure_hpa: rand(1000.0..1020.0).round(1),
      observed_at: log_date.to_datetime,
      snapshot: {
        weather_condition: weather_condition,
        wind_speed: rand(0..20),
        visibility: rand(5..30)
      }
    )

    # DailyLogに天気観測データを関連付け
    daily_log.update!(weather_observation: weather_observation)
  end
end

puts "✅ Created #{User.count} users."
puts "✅ Created #{Tag.count} tags."
puts "✅ Created #{Post.count} posts."
puts "✅ Created #{Location.count} locations."
puts "✅ Created #{WeatherObservation.count} weather observations."
puts "✅ Created #{DailyLog.count} daily logs."
puts "✅ Created #{PostTag.count} post tags."

puts "🎉 Seeding completed!"