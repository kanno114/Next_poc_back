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

# 投稿 + コメント + タグ付け
users.each_with_index do |user, idx|
  3.times do |i|
    post = Post.create!(
      title: "サンプル投稿#{idx + 1}-#{i + 1}",
      body: "これは#{user.name}によるサンプル投稿本文#{i + 1}です。",
      user: user
    )

    # ランダムタグ2つ
    post.tags << tags.sample(2)

    # 他ユーザーからランダムでコメント2件
    (users - [user]).sample(2).each_with_index do |comment_user, j|
      Comment.create!(
        body: "サンプルコメント#{j + 1}（#{user.name}の投稿#{i + 1}用）",
        user: comment_user,
        post: post
      )
    end
  end
end

puts "✅ Posts, tags, and comments created."
puts "🎉 Seeding completed!"
