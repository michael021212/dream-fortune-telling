require "faraday"
require "json"

class GeminiService
  GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent"

  class Error < StandardError; end

  def initialize
    @api_key = ENV["GEMINI_API_KEY"]
    raise Error, "GEMINI_API_KEY is not set" unless @api_key
  end

  def interpret_dream(dream_content)
    prompt = <<~PROMPT
      以下の夢の内容を解釈してください。
      回答は以下の2つの部分で構成してください：

      1. 簡単な解釈（50文字以内）
      2. 詳細な解釈（100文字以内）

      出力形式は以下の例と同じ構成になるよう出力してください(マークダウン記法は使わないこと。エスケープは使わないこと。summaryとinterpretationは小文字で出力すること)：
      {summary: 簡単な解釈（100文字以内}, {interpretation: 詳細な解釈（300文字以内）}

      夢の内容：
      #{dream_content}
    PROMPT

    response = client.post do |req|
      req.url "#{GEMINI_API_URL}?key=#{@api_key}"
      req.headers["Content-Type"] = "application/json"
      req.body = {
        contents: [ {
          parts: [ {
            text: prompt
          } ]
        } ]
      }.to_json
    end

    unless response.success?
      raise Error, "API request failed: #{response.status} - #{response.body}"
    end

    parse_response(response.body)
  rescue Faraday::Error => e
    raise Error, "Failed to connect to Gemini API: #{e.message}"
  rescue StandardError => e
    raise Error, "予期せぬエラーが発生しました: #{e.message}"
  end

  private

  def client
    @client ||= Faraday.new do |f|
      f.request :json
      f.request :retry, max: 2
      f.response :json
      f.adapter Faraday.default_adapter
    end
  end

  def parse_response(response)
    puts "response: #{response}"
    # "candidates" の配列が空でないことを確認
    candidate = response["candidates"]&.first
    raise "No candidate found in response" unless candidate

    # "content" の中の "parts" を取得
    parts = candidate.dig("content", "parts")
    raise "No parts found in response" if parts.nil? || parts.empty?

    # "text" を取得
    content = parts.first["text"]
    raise "No text found in response" unless content.is_a?(String)

    # 正規表現を使って summary と interpretation を抽出
    summary_match = content.match(/\{summary:\s*(.*?)\}/m)
    interpretation_match = content.match(/\{interpretation:\s*(.*?)\}/m)

    # それぞれの値を取得（見つからなかった場合は nil）
    summary = summary_match[1] if summary_match
    interpretation = interpretation_match[1] if interpretation_match

    # 結果を出力
    puts "Summary:\n#{summary}\n\n"
    puts "Interpretation:\n#{interpretation}"

    raise Error, "Failed to extract summary and interpretation" unless summary && interpretation

    {
      summary: summary,
      interpretation: interpretation
    }
  rescue JSON::ParserError => e
    raise Error, "Failed to parse response: #{e.message}"
  end
end
