require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'associations' do
    it { should have_many(:bill_of_landings).with_foreign_key('id_client') }
    it { should have_many(:invoices).through(:bill_of_landings) }
    it { should have_many(:refund_requests).through(:bill_of_landings) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(60) }
    it { should validate_length_of(:code).is_at_most(20) }
  end

  describe 'scopes' do
    let!(:active_customer) { create(:customer, status: :active) }
    let!(:inactive_customer) { create(:customer, status: :inactive) }
    let!(:priority_customer) { create(:customer, priority: true) }

    it 'returns active customers' do
      expect(Customer.active).to include(active_customer)
      expect(Customer.active).not_to include(inactive_customer)
    end

    it 'returns priority customers' do
      expect(Customer.priority).to include(priority_customer)
    end
  end

  describe '#display_name' do
    let(:customer) { create(:customer, name: 'ACME Corp', code: 'ACM001') }

    it 'returns formatted name with code' do
      expect(customer.display_name).to eq('ACME Corp (ACM001)')
    end
  end
end