module EnumConstants
  extend ActiveSupport::Concern
  included do
    OPEN ||= "OPEN".freeze
    INIT ||= "INIT".freeze
    PAID ||= "PAID".freeze
    CANCELED ||= "CANCELED".freeze
    CURRENCIES ||= %w[USD EUR XOF].freeze
    INVOICE_STATUSES ||= %w[OPEN, INIT, PAID, CANCELED].freeze
    PENDING ||= "PENDING".freeze
    APPROVED ||= "APPROVED".freeze
    REJECTED ||= "REJECTED".freeze
    PROCESSED ||= "PROCESSED".freeze
    REFUND_REQUEST_STATUSES ||= %w[PENDING APPROVED REJECTED PROCESSED].freeze
    ACTIVE ||= "ACTIVE".freeze
    INACTIVE ||= "INACTIVE".freeze
    CUSTOMER_STATUSES ||= %w[ACTIVE INACTIVE].freeze
    DRAFT ||= "DRAFT".freeze
    SUBMITTED ||= "SUBMITTED".freeze
    VALIDATED ||= "VALIDATED".freeze
    RELEASED ||= "RELEASED".freeze
    CANCELLED ||= "CANCELLED".freeze
    IS_VALID_VALAUES ||= [ 0, 1 ]
    BL_STATUSES ||= %w[
    DRAFT
    SUBMITTED
    VALIDATED
    RELEASED
    CANCELLED
  ].freeze
  end
end
