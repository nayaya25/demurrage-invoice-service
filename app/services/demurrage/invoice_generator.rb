module Demurrage
  class InvoiceGenerator
    def self.call
      new.call
    end

    def call
      count = 0
      bls_overdue_today.find_each do |bl|
        next if should_skip_bl?(bl)

        Demurrage::BlInvoiceCreatorInteractor.call(bl)
        count += 1
      end

      count
    end

    private

    def bls_overdue_today
      # BLs that became overdue TODAY (freetime expires today)
      BillOfLanding.overdue_today
    end

    def should_skip_bl?(bl)
      bl.has_open_invoice? || bl.has_pending_refund?
    end
  end
end