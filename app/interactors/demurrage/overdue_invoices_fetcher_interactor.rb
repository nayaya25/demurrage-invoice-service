module Demurrage
  class OverdueInvoicesFetcherInteractor

    def self.call
      new.call
    end

    def call
      Invoice.open
    end
  end
end