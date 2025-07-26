class RefundRequest < ApplicationRecord
  include EnumConstants
  self.table_name = 'remboursement'
  self.primary_key = 'id_remboursement'

  # Associations
  belongs_to :bill_of_landing, foreign_key: 'bl_number', primary_key: 'number'
  has_one :customer, through: :bill_of_landing

  # Validations
  validates :bl_number, presence: true, length: { is: 9 }
  validates :amount_requested, presence: true
  validates :forwarder_id, presence: true

  # Enum
  enum :status, {
    pending: EnumConstants::PENDING,
    approved: EnumConstants::APPROVED,
    processed: EnumConstants::PROCESSED,
    rejected: EnumConstants::REJECTED
  }

  # Scopes
  scope :pending, -> { where(status: :pending) }
  scope :approved, -> { where(status: :approved) }
  scope :processed, -> { where(status: :processed) }
  scope :recent, -> { order(request_date: :desc) }

  # Callbacks
  before_validation :set_defaults, on: :create

  def pending?
    status == EnumConstants::PENDING
  end

  def processed?
    status == EnumConstants::PROCESSED
  end

  def amount_requested_decimal
    return 0 unless amount_requested.present?
    amount_requested.to_f
  end

  private

  def set_defaults
    self.status ||= EnumConstants::PENDING
    self.request_date ||= Time.current
  end
end