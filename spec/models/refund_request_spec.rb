require 'rails_helper'

RSpec.describe RefundRequest, type: :model do
  describe 'associations' do
    it { should belong_to(:bill_of_landing).with_foreign_key('bl_number').with_primary_key('number') }
    it { should have_one(:customer).through(:bill_of_landing) }
  end

  describe 'validations' do
    subject { build(:refund_request, bill_of_landing: build(:bill_of_landing)) }

    it { should validate_presence_of(:bl_number) }
    it { should validate_length_of(:bl_number).is_equal_to(9) }
    it { should validate_presence_of(:amount_requested) }
    it { should validate_presence_of(:forwarder_id) }
  end

  describe 'enums' do
    it do
      should define_enum_for(:status).with_values(
        pending: EnumConstants::PENDING,
        approved: EnumConstants::APPROVED,
        processed: EnumConstants::PROCESSED,
        rejected: EnumConstants::REJECTED
      ).backed_by_column_of_type(:string)
    end
  end

  describe 'scopes' do
    let!(:pending_request) { create(:refund_request, status: :pending) }
    let!(:approved_request) { create(:refund_request, status: :approved) }
    let!(:processed_request) { create(:refund_request, status: :processed) }

    it 'returns pending requests' do
      expect(RefundRequest.pending).to include(pending_request)
      expect(RefundRequest.pending).not_to include(approved_request)
    end

    it 'returns approved requests' do
      expect(RefundRequest.approved).to include(approved_request)
      expect(RefundRequest.approved).not_to include(pending_request)
    end

    it 'returns processed requests' do
      expect(RefundRequest.processed).to include(processed_request)
    end
  end

  describe '#amount_requested_decimal' do
    it 'returns amount_requested as float' do
      request = build(:refund_request, amount_requested: '123.45')
      expect(request.amount_requested_decimal).to eq(123.45)
    end

    it 'returns 0 if amount_requested is nil' do
      request = build(:refund_request, amount_requested: nil)
      expect(request.amount_requested_decimal).to eq(0)
    end
  end
end
