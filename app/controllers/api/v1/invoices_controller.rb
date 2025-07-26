class Api::V1::InvoicesController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    generated_invoices_count = Demurrage::InvoiceGenerator.call

    render json: {
      message: "Invoice Generation Operation Completed",
      count: generated_invoices_count,
      timestamp: Time.current
    }, status: :created
  rescue => e
    render json: {
      error: "Invoice Generation Failed",
      message: e.message
    }, status: :unprocessable_content
  end
end
