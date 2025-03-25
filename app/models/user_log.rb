class UserLog < ApplicationRecord
  validates :line_user_id, presence: true
  validates :last_request_at, presence: true
  validates :warning_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.can_request?(line_user_id)
    log = find_or_initialize_by(line_user_id: line_user_id)
    return true if log.new_record?

    last_request = log.last_request_at
    return false if last_request.to_date == Time.current.to_date && log.warning_count >= 3

    true
  end

  def self.record_request(line_user_id)
    log = find_or_initialize_by(line_user_id: line_user_id)
    log.last_request_at = Time.current
    log.warning_count += 1 if log.warning_count < 3
    log.save!
  end

  def self.reset_warning_count(line_user_id)
    log = find_by(line_user_id: line_user_id)
    return unless log

    log.warning_count = 0
    log.save!
  end
end
