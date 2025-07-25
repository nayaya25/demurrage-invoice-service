# spec/models/invoice_spec.rb
require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'associations' do
    it { should belong_to(:bill_of_landing).with_foreign_key('bl_number').with_primary_key('number') }
    it { should have_one(:customer).through(:bill_of_landing) }
    it { should belong_to(:user).with_foreign_key('user_id').with_primary_key('id') }
  end

  describe 'validations' do
    subject do
      build(:invoice).tap do |i|
        i.status = EnumConstants::OPEN
        # Disable callback that fills customer_code/customer_name
        i.define_singleton_method(:sync_customer_details) {}
      end
    end

    it { should validate_presence_of(:reference) }
    it { should validate_length_of(:reference).is_at_most(10) }

    it { should validate_presence_of(:bl_number) }
    it { should validate_length_of(:bl_number).is_equal_to(9) }

    it { should validate_presence_of(:customer_code) }
    it { should validate_length_of(:customer_code).is_at_most(20) }

    it { should validate_presence_of(:customer_name) }
    it { should validate_length_of(:customer_name).is_at_most(60) }

    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }

    it { should validate_presence_of(:currency) }
    it { should validate_inclusion_of(:currency).in_array(EnumConstants::CURRENCIES) }

    it { should define_enum_for(:status).with_values(
      init: EnumConstants::INIT,
      open: EnumConstants::OPEN,
      canceled: EnumConstants::CANCELED,
      paid: EnumConstants::PAID
    ).backed_by_column_of_type(:string)
    }
  end

  describe 'scopes' do
    let!(:paid_invoice) { create(:invoice, status: EnumConstants::PAID) }
    let!(:open_invoice) { create(:invoice, status: EnumConstants::OPEN) }
    let!(:init_invoice) { create(:invoice, status: EnumConstants::INIT) }

    it 'returns open invoices' do
      expect(Invoice.open).to include(open_invoice)
      expect(Invoice.open).not_to include(paid_invoice)
    end

    it 'returns paid invoices' do
      expect(Invoice.paid).to include(paid_invoice)
      expect(Invoice.paid).not_to include(open_invoice)
    end

    it 'returns pending invoices' do
      expect(Invoice.pending).to match_array([open_invoice, init_invoice])
    end
  end

  describe '#overdue?' do
    it 'returns true for init or open statuses' do
      expect(build(:invoice, status: EnumConstants::INIT).overdue?).to be true
      expect(build(:invoice, status: EnumConstants::OPEN).overdue?).to be true
    end

    it 'returns false for paid or canceled' do
      expect(build(:invoice, status: EnumConstants::PAID).overdue?).to be false
      expect(build(:invoice, status: EnumConstants::CANCELED).overdue?).to be false
    end
  end

  describe '#amount_in_cents' do
    it 'returns the amount multiplied by 100 as integer' do
      invoice = build(:invoice, amount: 123.45)
      expect(invoice.amount_in_cents).to eq(12345)
    end
  end
end
