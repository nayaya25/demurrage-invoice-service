class Customer < ApplicationRecord
  include EnumConstants
  self.table_name = 'client'
  self.primary_key = 'id_client'

  # Associations
  has_many :bill_of_landings, foreign_key: 'id_client', dependent: :destroy
  has_many :invoices, through: :bill_of_landings
  has_many :refund_requests, through: :bill_of_landings

  # Enum
  enum :status, { active: ACTIVE, inactive: INACTIVE }

  # Validations
  validates :name, presence: true, length: { maximum: 60 }
  validates :code, length: { maximum: 20 }

  # Scopes
  scope :priority, -> { where(priority: true) }

  def display_name
    "#{name} (#{code})"
  end
end