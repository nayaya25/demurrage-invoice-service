require 'rails_helper'

RSpec.describe "POST /api/v1/invoices", type: :request do
  let(:headers) { { 'Content-Type' => 'application/json' } }

  describe "POST /api/v1/invoices" do
    context "when there are overdue BLs to process" do
      let!(:customer) { create(:customer) }
      let!(:overdue_bl_1) do
        create(:bill_of_landing,
               customer: customer,
               arrival_date: 10.days.ago,
               freetime: 5, # Overdue by 5 days
               containers_20ft_dry: 2,
               containers_40ft_dry: 1,
               exempted: false,
               is_valid: 1)
      end

      let!(:overdue_bl_2) do
        create(:bill_of_landing,
               customer: customer,
               arrival_date: 8.days.ago,
               freetime: 3, # Overdue by 5 days
               containers_20ft_dry: 1,
               containers_40ft_reefer: 2,
               exempted: false,
               is_valid: 1)
      end

      it "creates invoices for overdue BLs and returns success response" do
        expect {
          post "/api/v1/invoices", headers: headers
        }.to change(Invoice, :count).by(2)

        expect(response).to have_http_status(:created)

        response_body = JSON.parse(response.body)
        expect(response_body["message"]).to eq("Invoice Generation Operation Completed")
        expect(response_body["count"]).to eq(2)
        expect(response_body["timestamp"]).to be_present

        # Verify invoices were created correctly with new calculation
        invoice_1 = Invoice.find_by(bl_number: overdue_bl_1.number)
        defaulting_days_1 = overdue_bl_1.days_since_arrival - overdue_bl_1.freetime
        expected_amount_1 = overdue_bl_1.total_containers * defaulting_days_1 * 80.0

        expect(invoice_1).to be_present
        expect(invoice_1.amount).to eq(expected_amount_1) # 3 containers * 5 days * $80 = $1200
        expect(invoice_1.customer_code).to eq(customer.code)
        expect(invoice_1.status).to eq("open")

        invoice_2 = Invoice.find_by(bl_number: overdue_bl_2.number)
        defaulting_days_2 = overdue_bl_2.days_since_arrival - overdue_bl_2.freetime
        expected_amount_2 = overdue_bl_2.total_containers * defaulting_days_2 * 80.0

        expect(invoice_2).to be_present
        expect(invoice_2.amount).to eq(expected_amount_2) # 3 containers * 5 days * $80 = $1200
        expect(invoice_2.customer_code).to eq(customer.code)
      end

      it "generates proper invoice references" do
        post "/api/v1/invoices", headers: headers

        invoices = Invoice.last(2)
        invoices.each do |invoice|
          expect(invoice.reference).to match(/\ARF\d{6}[A-F0-9]{2}\z/)
          expect(invoice.reference).to include(Date.current.strftime('%y%m%d'))
        end
      end

      it "handles multiple container types correctly" do
        bl = create(:bill_of_landing,
                    customer: customer,
                    arrival_date: 10.days.ago,
                    freetime: 5, # 5 defaulting days
                    containers_20ft_dry: 1,
                    containers_40ft_dry: 2,
                    containers_20ft_reefer: 1,
                    containers_40ft_reefer: 1,
                    containers_20ft_special: 1,
                    containers_40ft_special: 1, # 7 total containers
                    exempted: false,
                    is_valid: 1)

        post "/api/v1/invoices", headers: headers

        invoice = Invoice.find_by(bl_number: bl.number)
        # 7 containers * 5 defaulting days * $80 = $2800
        expect(invoice.amount).to eq(2800.0)
      end
    end

    context "when there are no overdue BLs" do
      let!(:customer) { create(:customer) }
      let!(:current_bl) do
        create(:bill_of_landing,
               customer: customer,
               arrival_date: 2.days.ago,
               freetime: 10, # Still has 8 days left
               containers_20ft_dry: 2,
               exempted: false,
               is_valid: 1)
      end

      it "returns success with zero count" do
        post "/api/v1/invoices", headers: headers

        expect(response).to have_http_status(:created)

        response_body = JSON.parse(response.body)
        expect(response_body["count"]).to eq(0)
      end
    end

    context "when BLs are exempted" do
      let!(:customer) { create(:customer) }
      let!(:exempted_bl) do
        create(:bill_of_landing,
               customer: customer,
               arrival_date: 10.days.ago,
               freetime: 5,
               containers_20ft_dry: 2,
               exempted: true,
               is_valid: 1)
      end

      it "skips exempted BLs" do
        post "/api/v1/invoices", headers: headers

        expect(response).to have_http_status(:created)

        response_body = JSON.parse(response.body)
        expect(response_body["count"]).to eq(0)
      end
    end

    context "when BL has zero containers" do
      let!(:customer) { create(:customer) }
      let!(:zero_container_bl) do
        create(:bill_of_landing,
               customer: customer,
               arrival_date: 10.days.ago,
               freetime: 5,
               containers_20ft_dry: 0,
               containers_40ft_dry: 0,
               containers_20ft_reefer: 0,
               containers_40ft_reefer: 0,
               containers_20ft_special: 0,
               containers_40ft_special: 0,
               exempted: false,
               is_valid: 1)
      end

      it "skips BL with zero containers and doesn't increment count" do
        post "/api/v1/invoices", headers: headers

        expect(response).to have_http_status(:created)

        # Fixed: Count should be 0 since no invoice was created
        response_body = JSON.parse(response.body)
        expect(response_body["count"]).to eq(0)

        # No invoice should exist
        expect(Invoice.where(bl_number: zero_container_bl.number)).to be_empty
      end
    end

    context "when an error occurs during processing" do
      let!(:customer) { create(:customer) }
      let!(:overdue_bl) do
        create(:bill_of_landing,
               customer: customer,
               arrival_date: 10.days.ago,
               freetime: 5,
               containers_20ft_dry: 2,
               exempted: false,
               is_valid: 1)
      end

      before do
        # Mock an error in the invoice creation process
        allow(Demurrage::BlInvoiceCreatorInteractor).to receive(:call)
                                                          .and_raise(StandardError.new("Database connection failed"))
      end

      it "handles errors and returns error response" do
        post "/api/v1/invoices", headers: headers

        expect(response).to have_http_status(:unprocessable_content)

        response_body = JSON.parse(response.body)
        expect(response_body["error"]).to eq( "Invoice Generation Failed")
      end
    end

    context "edge cases and validations" do
      let!(:customer) { create(:customer) }

      it "handles multiple container types correctly" do
        bl = create(:bill_of_landing,
                    customer: customer,
                    arrival_date: 10.days.ago,
                    freetime: 5,
                    containers_20ft_dry: 1,
                    containers_40ft_dry: 2,
                    containers_20ft_reefer: 1,
                    containers_40ft_reefer: 1,
                    containers_20ft_special: 1,
                    containers_40ft_special: 1,
                    exempted: false,
                    is_valid: 1)

        post "/api/v1/invoices", headers: headers

        defaulting_days = [bl.days_since_arrival - bl.freetime, 0].max
        expected_amount = bl.total_containers * defaulting_days * 80.0
        invoice = Invoice.find_by(bl_number: bl.number)
        expect(invoice.amount).to eq(expected_amount)
      end

      it "validates that bl_number exists in bills of lading" do
        invalid_invoice = build(:invoice, bl_number: "INVALID99")

        expect(invalid_invoice).not_to be_valid
      end

      it "allows valid bl_number that exists" do
        bl = create(:bill_of_landing, customer: customer)
        valid_invoice = build(:invoice,
                              bl_number: bl.number,
                              customer_code: customer.code,
                              customer_name: customer.name)

        expect(valid_invoice).to be_valid
      end
    end
  end
end