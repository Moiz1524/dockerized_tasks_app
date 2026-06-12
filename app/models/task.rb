class Task < ApplicationRecord
  STATUSES = %w[pending in_progress completed].freeze
  PRIORITIES = %w[low medium high].freeze

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }

  scope :recent, -> { order(created_at: :desc) }
end
