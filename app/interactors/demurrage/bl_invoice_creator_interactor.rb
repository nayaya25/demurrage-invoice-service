module Demurrage
  class BlInvoiceCreatorInteractor
    DAILY_RATE_USD = 80.0

    def self.call(bl)
      new.call(bl)
    end

    def call(bl)
      total_containers = bl.total_containers
      return nil if total_containers.zero?

      create_invoice_for_bl(bl)
    end

    private
    def create_invoice_for_bl(bl)
      defaulting_days = [bl.days_since_arrival - bl.freetime, 0].max
      return nil if defaulting_days.zero?

      amount =  bl.total_containers * defaulting_days * DAILY_RATE_USD
      reference = generate_reference
      Invoice.create!(
        reference:,
        bl_number: bl.number,
        customer_code: bl.customer.code,
        customer_name: bl.customer.name,
        amount:,
        currency: "USD",
        status: :open,
        issued_date: Time.current,
        user_id: 1 # Generic user
      )
    end

    def generate_reference
      "RF#{Date.current.strftime('%y%m%d')}#{SecureRandom.hex(1).upcase}"
    end
  end
end