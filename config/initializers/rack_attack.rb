class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  throttle("req/ip", limit: 3, period: 1.minute) do |req|
    req.ip
  end

  throttle("webhook/ip", limit: 1, period: 30.seconds) do |req|
    if req.path == "/webhook"
      req.ip
    end
  end

  Rack::Attack.throttled_responder = lambda do |env|
    [
      429,
      { "Content-Type" => "text/plain" },
      ["Too many requests. Please try again later."]
    ]
  end
end 
