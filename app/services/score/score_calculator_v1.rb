module Score
  class ScoreCalculatorV1

    W = {
      top_body: 0.7, top_env: 0.3,
      body: { sleep: 0.6, mood: 0.4 },
      env:  { press_drop: 0.40, humid: 0.25, temp: 0.35 }
    }.freeze

    def initialize(daily_log)
      @log = daily_log
      @weather_observation = daily_log.weather_observation
    end

    def call
      stats = aggregate_env(@log)   # 当日の集計（平均/差分）
      norms = normalize(@log, stats)

      b = combine_body(norms)
      e = combine_env(norms)

      raw = 100.0 * (W[:top_body]*b + W[:top_env]*e)
      score = raw.round.clamp(0, 100)

      @log.update!(score:)

      { score:, details: { norms:, env_stats: stats } }
    end

    private

    # === 集計 ===
    def aggregate_env(log)
      obs = WeatherObservation.in_range(log.jst_range)
      temps  = obs.pluck(:temperature_c)
      hums   = obs.pluck(:humidity_pct)
      press  = obs.pluck(:pressure_hpa)

      {
        temp_mean: temps.sum.to_f / temps.size,
        hum_mean:  hums.sum.to_f  / hums.size,
        press_drop_24h: press.max - press.min  # 当日内の最大→最小の差 = 低下量(≧0)
      }
    end

    # === 正規化（0..1） ===
    def normalize(log, s)
      {
        sleep: sleep_norm(log.sleep_hours),
        mood:  linear_norm(log.mood, -5, 5),
        press_drop: cap_norm(s[:press_drop_24h], cap: 10, inverse: true), # 10hPa低下で悪影響=1
        humid: discomfort_humid(s[:hum_mean]),
        temp:  discomfort_temp(s[:temp_mean])
      }
    end

    # mood: -5..5 -> 0..1
    def linear_norm(x, min, max)
      [[(x - min) / (max - min).to_f, 0.0].max, 1.0].min
    end

    # 値が小さいほど良い（例: pm2.5, 低下量など）
    def cap_norm(x, cap:, inverse:)
      v = [[x.to_f / cap, 0.0].max, 1.0].min
      inverse ? (1.0 - v) : v
    end

    # ステップ関数による正規化
    def step_norm(x, max:, inverse:)
      v = [[x.to_f / max, 0.0].max, 1.0].min
      inverse ? (1.0 - v) : v
    end

    # 7–8h で最大、それ以外は落ちる（U字）
    def sleep_norm(h)
      h = h.to_f
      return 0.1 if h < 4
      return 0.6 if h > 12
      if h < 6      then 0.1 + (h - 4) / 2 * 0.6      # 4→6h: 0.1→0.7
      elsif h <= 8  then 0.7 + (h - 6) / 2 * 0.3      # 6→8h: 0.7→1.0
      elsif h <= 9.5 then 1.0 - (h - 8) / 1.5 * 0.2   # 8→9.5h: 1.0→0.8
      else 0.7
      end
    end

    def discomfort_humid(h)
      # 40–60% が快適(=0)、離れるほど1へ
      if (40..60).cover?(h) then 1.0 - 0.0
      else [[(h - 50).abs / 40.0, 0.0].max, 1.0].min.then { |pen| 1.0 - pen }
      end
    end

    def discomfort_temp(t)
      # 20–25℃ が快適(=0)、離れるほど1へ
      if (20..25).cover?(t) then 1.0 - 0.0
      else [[(t - 22.5).abs / 12.5, 0.0].max, 1.0].min.then { |pen| 1.0 - pen }
      end
    end

    # === 合成 ===
    def combine_body(n)
      W[:body][:sleep] * n[:sleep] + W[:body][:mood] * n[:mood]
    end

    def combine_env(n)
      # ここは「快適度」で 1 が良い値
      # press_drop は "値が低いほど良い" なので上で反転済み
      W[:env][:press_drop] * n[:press_drop] + 
      W[:env][:humid] * n[:humid] + 
      W[:env][:temp] * n[:temp]
    end
  end
end