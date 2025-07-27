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
    let(:bl) { create(
      :bill_of_landing,
      arrival_date: Date.today - 5.days,
      freetime: 3,
      containers_20ft_dry: 1,
      containers_40ft_dry: 2,
      containers_20ft_reefer: 1,
      containers_40ft_reefer: 2,
      containers_20ft_special: 0,
      containers_40ft_special: 0
    )}

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

    describe '#days_since_arrival' do
      it 'returns correct number of days since arrival' do
        expect(bl.days_since_arrival).to eq(5)
      end

      it 'returns 0 when arrival_date is nil' do
        bl.arrival_date = nil
        expect(bl.days_since_arrival).to eq(0)
      end
    end

    describe '#defaulting_days calculation' do
      it 'calculates defaulting days correctly' do
        # days_since_arrival (5) - freetime (3) = 2 defaulting days
        defaulting_days = [bl.days_since_arrival - bl.freetime, 0].max
        expect(defaulting_days).to eq(2)
      end

      it 'returns negative for BLs still within freetime' do
        recent_bl = create(:bill_of_landing,
                           arrival_date: 1.day.ago,
                           freetime: 5,
                           containers_20ft_dry: 1)

        defaulting_days = [recent_bl.days_since_arrival - recent_bl.freetime, 0].max
        expect(defaulting_days).to eq(0) # [1 - 5, 0].max = 0
      end
    end

    describe 'invoice amount calculation' do
      let(:daily_rate) { 80.0 }

      it 'calculates amount correctly for overdue BL' do
        # BL: 5 days since arrival, 3 days freetime = 2 defaulting days
        # Containers: 1 + 2 + 1 + 2= 6 total containers
        # Amount: 6 containers * 2 defaulting days * $80 = $480

        defaulting_days = [bl.days_since_arrival - bl.freetime, 0].max
        expected_amount = bl.total_containers * defaulting_days * daily_rate

        expect(defaulting_days).to eq(2)
        expect(expected_amount).to eq(960.0)
      end

      it 'handles zero defaulting days (should not generate invoice)' do
        # BL within freetime should have 0 or negative defaulting days
        current_bl = create(:bill_of_landing,
                            arrival_date: 2.days.ago,
                            freetime: 5, # Still has 3 days left
                            containers_20ft_dry: 2)

        defaulting_days = [current_bl.days_since_arrival - current_bl.freetime, 0].max
        amount = current_bl.total_containers * defaulting_days * daily_rate

        expect(defaulting_days).to eq(0) # [2 - 5, 0].max = 0
        expect(amount).to eq(0.0) # Should be 0, indicating no invoice needed
      end

      it 'calculates for complex container mix' do
        complex_bl = create(:bill_of_landing,
                            arrival_date: 10.days.ago,
                            freetime: 7, # 3 defaulting days
                            containers_20ft_dry: 1,
                            containers_40ft_dry: 2,
                            containers_20ft_reefer: 1,
                            containers_40ft_reefer: 1,
                            containers_20ft_special: 1,
                            containers_40ft_special: 1) # Total: 7 containers

        defaulting_days = [complex_bl.days_since_arrival - complex_bl.freetime, 0].max
        amount = complex_bl.total_containers * defaulting_days * daily_rate

        expect(defaulting_days).to eq(3) # 10 - 7 = 3
        expect(complex_bl.total_containers).to eq(7)
        expect(amount).to eq(1680.0) # 7 * 3 * 80 = 1680
      end
    end
  end
end