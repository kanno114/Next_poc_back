module Score
  class ScoreCalculatorV1

    W = {
      top_body: 0.7, top_env: 0.3,
      body: { sleep: 0.6, mood: 0.4 },
      env:  { press_drop: 0.40, humid: 0.25, temp: 0.20, pm25: 0.10, pollen: 0.05 }
    }.freeze

    def initialize(daily_log)
      @log = daily_log
      @weather_observation = daily_log.weather_observation
    end

    def call(persist: true)
      stats = aggregate_env(@log)   # 当日の集計（平均/差分）
      norms = normalize(@log, stats)

      b = combine_body(norms)
      e = combine_env(norms)
      m = modifiers(@log, stats)

      # 欠損再配分
      b = redistribute_if_missing(b[:val], b[:weight_sum])
      e = redistribute_if_missing(e[:val], e[:weight_sum])

      raw = 100.0 * (W[:top_body]*b + W[:top_env]*e) + m
      score = raw.round.clamp(0, 100)

      if persist
        @log.update!(score:)
      end

      { score:, details: { norms:, m:, env_stats: stats } }
    end

    private

    # === 集計 ===
    def aggregate_env(log)
      obs = WeatherObservation.in_range(log.jst_range)
      temps  = obs.where.not(temperature_c: nil).pluck(:temperature_c)
      hums   = obs.where.not(humidity_pct: nil).pluck(:humidity_pct)
      press  = obs.where.not(pressure_hpa: nil).pluck(:pressure_hpa)
      snaps  = obs.where.not(snapshot: nil).pluck(:snapshot)

      {
        temp_mean: temps.presence&.sum.to_f / [temps.size, 1].max,
        hum_mean:  hums.presence&.sum.to_f  / [hums.size, 1].max,
        press_drop_24h: press.presence ? (press.max - press.min) : nil,  # 当日内の最大→最小の差 = 低下量(≧0)
        pm25_mean: avg_from_snaps(snaps, "pm25"),
        pollen_max: max_from_snaps(snaps, "pollen_index")
      }
    end

    def avg_from_snaps(snaps, key)
      vals = snaps.filter_map { |h| h[key] if h.is_a?(Hash) && h.key?(key) }.map(&:to_f)
      return nil if vals.empty?
      vals.sum / vals.size
    end

    def max_from_snaps(snaps, key)
      vals = snaps.filter_map { |h| h[key] if h.is_a?(Hash) && h.key?(key) }.map(&:to_f)
      return nil if vals.empty?
      vals.max
    end

    # === 正規化（0..1） ===
    def normalize(log, s)
      {
        sleep: sleep_norm(log.sleep_hours),
        mood:  linear_norm(log.mood, -5, 5),
        press_drop: cap_norm(s[:press_drop_24h], cap: 10, inverse: true), # 10hPa低下で悪影響=1 → inverse:true で快適側に反転しない点に注意
        humid: discomfort_humid(s[:hum_mean]),
        temp:  discomfort_temp(s[:temp_mean]),
        pm25:  cap_norm(s[:pm25_mean], cap: 50, inverse: true),
        pollen: step_norm(s[:pollen_max], max: 5, inverse: true)
      }.compact
    end

    # mood: -5..5 -> 0..1
    def linear_norm(x, min, max)
      return nil if x.nil?
      [[(x - min) / (max - min).to_f, 0.0].max, 1.0].min
    end

    # 値が小さいほど良い（例: pm2.5, 低下量など）
    def cap_norm(x, cap:, inverse:)
      return nil if x.nil?
      v = [[x.to_f / cap, 0.0].max, 1.0].min
      inverse ? (1.0 - v) : v
    end

    # ステップ関数による正規化
    def step_norm(x, max:, inverse:)
      return nil if x.nil?
      v = [[x.to_f / max, 0.0].max, 1.0].min
      inverse ? (1.0 - v) : v
    end

    # 7–8h で最大、それ以外は落ちる（U字）
    def sleep_norm(h)
      return nil if h.nil?
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
      return nil if h.nil?
      # 40–60% が快適(=0)、離れるほど1へ
      if (40..60).cover?(h) then 1.0 - 0.0
      else [[(h - 50).abs / 40.0, 0.0].max, 1.0].min.then { |pen| 1.0 - pen }
      end
    end

    def discomfort_temp(t)
      return nil if t.nil?
      # 20–25℃ が快適(=0)、離れるほど1へ
      if (20..25).cover?(t) then 1.0 - 0.0
      else [[(t - 22.5).abs / 12.5, 0.0].max, 1.0].min.then { |pen| 1.0 - pen }
      end
    end

    # === 合成（欠損は重み再配分） ===
    def combine_body(n)
      parts = []
      wsum  = 0.0
      if n[:sleep]
        parts << W[:body][:sleep] * n[:sleep]; wsum += W[:body][:sleep]
      end
      if n[:mood]
        parts << W[:body][:mood] * n[:mood];   wsum += W[:body][:mood]
      end
      { val: parts.sum, weight_sum: wsum }
    end

    def combine_env(n)
      # ここは「快適度」で 1 が良い値
      # press_drop, pm25, pollen は "値が低いほど良い" なので上で反転済み
      items = {
        press_drop: W[:env][:press_drop],
        humid:      W[:env][:humid],
        temp:       W[:env][:temp],
        pm25:       W[:env][:pm25],
        pollen:     W[:env][:pollen]
      }
      val = 0.0; wsum = 0.0
      items.each do |k, w|
        next unless n[k]
        val += w * n[k]; wsum += w
      end
      { val:, weight_sum: wsum }
    end

    def redistribute_if_missing(weighted_val, weight_sum)
      return 0.5 if weight_sum.zero? # 全欠損→中立値
      (weighted_val / weight_sum).clamp(0.0, 1.0)
    end

    # === 補正 ===
    def modifiers(log, s)
      m = 0
      m -= 8  if s[:press_drop_24h] && s[:press_drop_24h] >= 6.0
      m -= 5  if s[:pollen_max] && s[:pollen_max] >= 4
      m -= 10 if log.sleep_hours && log.sleep_hours < 4
      m
    end
  end
end