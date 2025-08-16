require 'bcrypt'

puts "🌱 Seeding started..."

# 初期化（順番に注意）
WeatherObservation.delete_all
PostTag.delete_all
Post.delete_all
Location.delete_all
Tag.delete_all
UserIdentity.delete_all
User.delete_all

# タグ作成
tag_names = %w[テスト サンプル Rails React Ruby 旅行 グルメ 観光 自然 文化 歴史 アート スポーツ 温泉 夜景 神社 寺 公園 博物館 美術館 レストラン カフェ ショッピング 季節]
tags = tag_names.map { |name| Tag.find_or_create_by!(name: name) }

puts "✅ Created #{tags.count} tags."

# ユーザー作成
users = []
8.times do |i|
  users << User.find_or_create_by!(email: "testuser#{i + 1}@example.com") do |u|
    u.name = "テストユーザー#{i + 1}"
    u.password_digest = BCrypt::Password.create("testtest")
  end
end

puts "✅ Created #{users.count} users."

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

# 投稿 + 天気観測データ + タグ付け
users.each_with_index do |user, idx|
  15.times do |i| # 各ユーザーに15件ずつ投稿を作成（合計120件）

    # 首都圏内の座標を決定
    latitude = rand(CAPITAL_AREA_LAT_RANGE)
    longitude = rand(CAPITAL_AREA_LNG_RANGE)

    # Locationを作成または取得
    location = Location.find_or_create_by!(
      latitude: latitude.round(6),
      longitude: longitude.round(6)
    )

    # 投稿テンプレートからランダム選択
    template = post_templates.sample

    # イベント日時を過去1ヶ月以内のランダムな日付に設定
    event_datetime = Date.current - rand(0..30)

    post = Post.create!(
      title: "#{template[:title]}",
      body: "#{template[:body]}",
      user: user,
      location: location,
      event_datetime: event_datetime
    )

    # ランダムに1-3個のタグを付与
    post.tags << tags.sample(rand(1..3))

    # 全ての投稿に天気観測データを作成
    WeatherObservation.create!(
      post: post,
      temperature_c: rand(-5.0..35.0).round(1),
      humidity_pct: rand(30..90),
      pressure_hpa: rand(1000.0..1020.0).round(1),
      observed_at: event_datetime.to_datetime,
      snapshot: {
        weather_condition: %w[晴れ 曇り 雨 雪].sample,
        wind_speed: rand(0..20),
        visibility: rand(5..30)
      }
    )
  end
end

puts "✅ Created #{Post.count} posts."
puts "✅ Created #{Location.count} locations."
puts "✅ Created #{WeatherObservation.count} weather observations."
puts "✅ Created #{PostTag.count} post tags."

puts "✅ Posts, tags, and weather observations created."
puts "🎉 Seeding completed!"