class Customer < ApplicationRecord
  self.table_name = 'client'
  self.primary_key = 'id_client'

  # Associations
  has_many :bill_of_landings, foreign_key: 'id_client', dependent: :destroy
  has_many :invoices, through: :bill_of_landings
  has_many :refund_requests, through: :bill_of_landings

  # Validations
  validates :name, presence: true, length: { maximum: 60 }
  validates :code, length: { maximum: 20 }
  validates :nom_groupe, presence: true, length: { maximum: 150 }
  validates :paie_caution, inclusion: { in: [true, false] }

  # Scopes
  scope :active, -> { where.not(statut: 'inactive') }
  scope :priority, -> { where(prioritaire: true) }

  def display_name
    "#{name} (#{code})"
  end
end