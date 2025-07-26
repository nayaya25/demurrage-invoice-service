require 'rails_helper'

RSpec.describe BillOfLanding, type: :model do
  describe 'associations' do
    it { should belong_to(:customer).with_foreign_key('id_client').optional }
    it { should have_many(:invoices).with_foreign_key('bl_number').dependent(:destroy) }
    it { should have_many(:refund_requests).with_foreign_key('bl_number').dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:number) }
    it { should validate_length_of(:number).is_equal_to(9) }

    it { should validate_presence_of(:arrival_date) }
    it { should validate_presence_of(:freetime) }
    it { should validate_numericality_of(:freetime).is_greater_than(0) }

    it { should validate_length_of(:vessel_name).is_at_most(30) }
    it { should validate_length_of(:consignee_name).is_at_most(60) }

    %w[containers_20ft_dry containers_40ft_dry containers_20ft_reefer
       containers_40ft_reefer containers_20ft_special containers_40ft_special].each do |attr|
      it { should validate_numericality_of(attr).is_greater_than_or_equal_to(0).only_integer.allow_nil }
    end
  end

  describe 'scopes' do
    let!(:valid_bl) { create(:bill_of_landing, is_valid: 1, exempted: false, arrival_date: 2.days.ago, containers_20ft_dry: 1) }
    let!(:invalid_bl) { create(:bill_of_landing, is_valid: 0, exempted: true, arrival_date: 5.days.from_now, containers_20ft_dry: 0) }

    it 'returns not exempted B/Ls' do
      expect(BillOfLanding.not_exempt).to include(valid_bl)
      expect(BillOfLanding.not_exempt).not_to include(invalid_bl)
    end
  end

  describe 'methods' do
    let(:bl) { create(:bill_of_landing, arrival_date: Date.today - 5.days, freetime: 3, containers_20ft_dry: 1, containers_40ft_dry: 2) }

    describe '#freetime_expires_on' do
      it 'returns the expected expiry date' do
        expect(bl.freetime_expires_on).to eq((Date.today - 5.days) + 3.days)
      end
    end

    describe '#overdue_as_of?' do
      it 'returns true if the date is past freetime expiry' do
        expect(bl.overdue_as_of?(Date.today)).to be true
      end
    end

    describe '#days_overdue' do
      it 'returns correct number of overdue days' do
        expect(bl.days_overdue(Date.today)).to eq(2)
      end
    end
  end
end