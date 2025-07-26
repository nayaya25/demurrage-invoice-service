class InvoicesController < ApplicationController
  def index
    @invoices = Demurrage::OverdueInvoicesFetcherInteractor.call
  end
end