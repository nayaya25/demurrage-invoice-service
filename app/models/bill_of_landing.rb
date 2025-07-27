class BillOfLanding < ApplicationRecord
  include EnumConstants
  self.table_name = 'bl'
  self.primary_key = 'id_bl'

  # Associations
  belongs_to :customer, foreign_key: 'id_client', optional: true
  has_many :invoices, foreign_key: 'bl_number', primary_key: 'number', dependent: :destroy
  has_many :refund_requests, foreign_key: 'bl_number', primary_key: 'number', dependent: :destroy

  # Validations
  validates :number, presence: true, uniqueness: true, length: { is: 9 }
  validates :arrival_date, presence: true
  validates :freetime, presence: true, numericality: { greater_than: 0 }
  validates :vessel_name, length: { maximum: 30 }
  validates :consignee_name, length: { maximum: 60 }

  # Enum
  enum :status, {
    draft: "DRAFT",
    submitted: "SUBMITTED",
    validated: "VALIDATED",
    released: "RELEASED",
    cancelled: "CANCELLED"
  }

  # Added Container count validations - to ensure non-negative integers
  %w[containers_20ft_dry containers_40ft_dry containers_20ft_reefer
     containers_40ft_reefer containers_20ft_special containers_40ft_special].each do |attr|
    validates attr, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  end

  # Scopes
  scope :not_exempt, -> { where(exempted: false) }

  # Business logic methods
  def total_containers
    [
      containers_20ft_dry, containers_40ft_dry,
      containers_20ft_reefer, containers_40ft_reefer,
      containers_20ft_special, containers_40ft_special
    ].compact.sum
  end

  def days_since_arrival
    return 0 unless arrival_date
    (Date.current - arrival_date.to_date).to_i
  end

  def self.overdue_today
    today = Date.current
    joins(:customer)
      .where("DATE(arrival_date + INTERVAL freetime DAY) < ?", today)
      .where(exempted: false, is_valid: 1)
      .includes(:customer, :invoices)
  end

  def freetime_expires_on
    return nil unless arrival_date && freetime
    arrival_date.to_date + freetime.days
  end

  def overdue_as_of?(date = Date.current)
    return false unless freetime_expires_on
    date > freetime_expires_on
  end

  def days_overdue(as_of_date = Date.current)
    return 0 unless overdue_as_of?(as_of_date)
    (as_of_date - freetime_expires_on).to_i
  end

  def has_open_invoice?
    invoices.where.not(status: :paid).exists?
  end

  def has_pending_refund?
    refund_requests.where(status: :pending).exists?
  end

  def blocked_for_invoicing?
    exempted? || blocked_for_refund?
  end

  # Demorrage queries
  def self.becoming_overdue_on(date)
    where("DATE(arrival_date + INTERVAL freetime DAY) = ?", date)
  end

  def self.overdue_as_of(date = Date.current)
    where("DATE(arrival_date + INTERVAL freetime DAY) < ?", date)
  end
end