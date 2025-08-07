require 'bcrypt'

puts "🌱 Seeding started..."

# 初期化（順番に注意）
Comment.delete_all
PostTag.delete_all
Post.delete_all
Tag.delete_all
User.delete_all

# タグ作成
tag_names = %w[テスト サンプル Rails React Ruby]
tags = tag_names.map { |name| Tag.find_or_create_by!(name: name) }

puts "✅ Created #{tags.count} tags."

# ユーザー作成
users = []
5.times do |i|
  users << User.find_or_create_by!(email: "testuser#{i + 1}@example.com") do |u|
    u.name = "テストユーザー#{i + 1}"
    u.password_digest = BCrypt::Password.create("testtest")
    u.provider = "email"
  end
end

puts "✅ Created #{users.count} users."

# 東京都内の緯度・経度の範囲
TOKYO_LAT_RANGE = (35.6..35.8) # 緯度
TOKYO_LNG_RANGE = (139.6..139.8) # 経度

# 日本国内の緯度・経度の範囲
JAPAN_LAT_RANGE = (24.396308..45.551483) # 緯度（沖縄から北海道）
JAPAN_LNG_RANGE = (122.93457..153.986672) # 経度（日本の東西端）

# 投稿 + コメント + タグ付け
users.each_with_index do |user, idx|
  20.times do |i| # 各ユーザーに20件ずつ投稿を作成（合計100件）
    is_tokyo = i < 2 # 最初の2件は東京内（合計10件）

    post = Post.create!(
      title: "サンプル投稿#{idx + 1}-#{i + 1}",
      body: "これは#{user.name}によるサンプル投稿本文#{i + 1}です。",
      user: user,
      latitude: is_tokyo ? rand(TOKYO_LAT_RANGE) : rand(JAPAN_LAT_RANGE),  # 東京または日本国内のランダムな緯度
      longitude: is_tokyo ? rand(TOKYO_LNG_RANGE) : rand(JAPAN_LNG_RANGE) # 東京または日本国内のランダムな経度
    )

    # ランダムタグ2つ
    post.tags << tags.sample(2)

    # 他ユーザーからランダムでコメント2件
    (users - [user]).sample(2).each_with_index do |comment_user, j|
      Comment.create!(
        body: "サンプルコメント#{j + 1}（#{user.name}の投稿#{i + 1}用）",
        user: comment_user,
        post: post,
      )
    end
  end
end

puts "✅ Created #{Post.count} posts."
puts "✅ Created #{Comment.count} comments."

puts "✅ Posts, tags, and comments created."
puts "🎉 Seeding completed!"
