class InvoicesController < ApplicationController
  def index
    @invoices = Demurrage::OverdueInvoicesFetcherInteractor.call
    p "INVOICES OVERDUE", @invoices
  end
end