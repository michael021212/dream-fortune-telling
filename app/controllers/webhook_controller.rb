class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :validate_signature
  before_action :validate_message

  def create
    puts "create action start"
    line_user_id = params[:events][0][:source][:userId]
    
    if BannedUser.banned?(line_user_id)
      reply_message("申し訳ありませんが、現在ご利用いただけません。")
      return
    end

    unless UserLog.can_request?(line_user_id)
      reply_message("本日の利用制限に達しました。明日またお試しください。")
      return
    end

    message = params[:events][0][:message][:text]
    
    if inappropriate_content?(message)
      UserLog.record_request(line_user_id)
      reply_message("不適切な内容が含まれています。内容を修正して再度お試しください。")
      return
    end

    begin
      interpretation = GeminiService.new.interpret_dream(message)
      UserLog.record_request(line_user_id)

      # 開発用に利用制限をリセット
      UserLog.reset_warning_count(line_user_id)
      
      reply_message(<<~MESSAGE)
        【簡単な解釈】
        #{interpretation[:summary]}

        【詳細な解釈】
        #{interpretation[:interpretation]}
      MESSAGE
    rescue GeminiService::Error => e
      Rails.logger.error("Gemini API Error: #{e.message}")
      reply_message("申し訳ありません。現在サービスに問題が発生しています。しばらく時間をおいて再度お試しください。")
    end
  end

  private

  def validate_signature
    signature = request.headers["X-Line-Signature"]
    body = request.body.read
    unless Line::Client.validate_signature(body, signature)
      head :bad_request # リクエスト元(LINE)に400を返して終了
    end
  end

  def validate_message
    return true if params[:events]&.first&.dig(:message, :type) == "text"
    
    # テキストメッセージ以外はその旨を返信
    reply_message("申し訳ありませんが、テキストメッセージのみ対応しています。")
    head :ok # リクエスト元(LINE)に200を返して終了
  end

  # AIによる生成そのまま。フィルタリングをしたいんだろうけどこの方法では意味ない
  def inappropriate_content?(message)
    inappropriate_words = %w[暴力 差別 性的 殺人 自殺 薬物 犯罪]
    inappropriate_words.any? { |word| message.include?(word) }
  end

  def reply_message(message)
    Line::Client.reply_message(
      params[:events][0][:replyToken],
      {
        type: "text",
        text: message
      }
    )
    head :ok
  end
end 
