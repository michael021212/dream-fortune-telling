class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # リクエストの制限を設定
  Rack::Attack.throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/webhook')
  end

  # LINE Webhookの制限を設定
  Rack::Attack.throttle('webhook/ip', limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/webhook')
  end

  # ブロックされたリクエストのレスポンス
  Rack::Attack.throttled_responder = lambda do |env|
    [
      429, # status
      { 'Content-Type' => 'application/json' },
      [{ error: 'Too many requests' }.to_json]
    ]
  end
end
