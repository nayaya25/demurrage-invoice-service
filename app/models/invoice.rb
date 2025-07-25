class Invoice < ApplicationRecord
  include EnumConstants
  self.table_name = 'facture'
  self.primary_key = 'id_facture'

  # Associations
  belongs_to :bill_of_landing, foreign_key: 'bl_number', primary_key: 'number'
  has_one :customer, through: :bill_of_landing
  belongs_to :user, foreign_key: 'user_id', primary_key: 'id'

  # Validations
  validates :reference, presence: true, uniqueness: true, length: { maximum: 10 }
  validates :bl_number, presence: true, length: { is: 9 }
  validates :customer_code, presence: true, length: { maximum: 20 }
  validates :customer_name, presence: true, length: { maximum: 60 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: EnumConstants::CURRENCIES }

  # Enum
  enum :status, { init: EnumConstants::INIT, open: EnumConstants::OPEN, canceled: EnumConstants::CANCELED, paid: PAID }

  # Scopes
  scope :open, -> { where(status: EnumConstants::OPEN) }
  scope :paid, -> { where(status: EnumConstants::PAID) }
  scope :pending, -> { where(status: [ EnumConstants::INIT, EnumConstants::OPEN ]) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_validation :set_defaults, on: :create
  before_validation :sync_customer_details

  def overdue?
    init? || open?
  end

  def amount_in_cents
    (amount * 100)
  end

  private

  def set_defaults
    self.status ||= EnumConstants::OPEN
    self.issued_date ||= Time.current
  end

  def sync_customer_details
    return unless bill_of_landing&.customer

    self.customer_code = bill_of_landing.customer.code
    self.customer_name = bill_of_landing.customer.name
  end
end