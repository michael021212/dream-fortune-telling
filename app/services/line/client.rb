module Line
  class Client
    class << self
      def instance
        @instance ||= Line::Bot::Client.new do |config|
          config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
          config.channel_token = ENV["LINE_CHANNEL_ACCESS_TOKEN"]
        end
      end

      def method_missing(name, *args)
        instance.send(name, *args)
      end
    end
  end
end
