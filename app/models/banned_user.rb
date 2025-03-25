class BannedUser < ApplicationRecord
  validates :line_user_id, presence: true, uniqueness: true
  validates :banned_at, presence: true
  validates :reason, presence: true

  def self.banned?(line_user_id)
    exists?(line_user_id: line_user_id)
  end

  def self.ban(line_user_id, reason)
    create!(
      line_user_id: line_user_id,
      banned_at: Time.current,
      reason: reason
    )
  end
end
