# ─────────────────────────────
# 1. ベースイメージ
# ─────────────────────────────
FROM ruby:3.3.6

# ─────────────────────────────
# 2. 必要なパッケージ
# ─────────────────────────────
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends nodejs build-essential postgresql-client

# ─────────────────────────────
# 3. 作業ディレクトリ
# ─────────────────────────────
WORKDIR /app

# ─────────────────────────────
# 4. Gemインストール
# ─────────────────────────────
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# ─────────────────────────────
# 5. アプリケーションコード
# ─────────────────────────────
COPY . .

# ─────────────────────────────
# 6. ポート
# ─────────────────────────────
EXPOSE 3000

# ─────────────────────────────
# 7. Entrypoint
# ─────────────────────────────
CMD ["bash", "-lc", "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0 -p 3000"]