require 'rails_helper'
require Rails.root.join('spec', 'validators', 'start_end_date_validator_spec')
require Rails.root.join('spec', 'models', 'concerns', 'time_periodable_spec')

RSpec.describe SpentFinance do
  it_behaves_like 'TimePeriodable'
  include_examples 'StartEndDateValidator'

  let(:new_spent_finance) do
    FactoryGirl.build(:spent_finance)
  end

  let(:spent_finance1) do
    FactoryGirl.create(
      :spent_finance,
      start_date: Date.new(2014, 12, 1),
      end_date: Date.new(2014, 12, 31)
    )
  end

  let(:spent_finance1b) do
    FactoryGirl.create(
      :spent_finance,
      start_date: spent_finance1.time_period_obj.next.start_date,
      end_date: spent_finance1.time_period_obj.next.end_date,
      finance_spendable: spent_finance1.finance_spendable
    )
  end

  let(:spent_finance1c) do
    FactoryGirl.create(
      :spent_finance,
      start_date: spent_finance1b.time_period_obj.next.start_date,
      end_date: spent_finance1b.time_period_obj.next.end_date,
      finance_spendable: spent_finance1b.finance_spendable
    )
  end

  let(:spent_finance1d) do
    FactoryGirl.create(
      :spent_finance,
      start_date: spent_finance1c.time_period_obj.next.start_date,
      end_date: spent_finance1c.time_period_obj.next.end_date,
      finance_spendable: spent_finance1c.finance_spendable
    )
  end

  let(:spent_finance2) { FactoryGirl.create(:spent_finance) }

  it 'is valid with valid attributes' do
    expect(new_spent_finance).to be_valid
  end

  describe '#official' do
    it 'is required' do
      new_spent_finance.official = nil

      expect(new_spent_finance.valid?).to eq(false)
      expect(new_spent_finance).to have(1).error_on(:official)
    end
  end

  describe 'time period' do
    context 'when finance is official' do
      it 'is unique' do
        spent_finance1.update_attribute(:official, true)
        spent_finance1b.official = true
        spent_finance1b.start_date = spent_finance1.start_date
        spent_finance1b.end_date = spent_finance1.end_date

        expect(spent_finance1b).to have(1).error_on(:end_date)
      end
    end

    context 'when finance is unofficial' do
      it 'does not have to be unique' do
        spent_finance1.update_attribute(:official, true)
        spent_finance1b.official = false
        spent_finance1b.start_date = spent_finance1.start_date
        spent_finance1b.end_date = spent_finance1.end_date

        expect(spent_finance1b).to have(0).error_on(:end_date)
      end
    end
  end

  describe '#finance_spendable' do
    it 'is required' do
      new_spent_finance.finance_spendable = nil

      expect(new_spent_finance).to have(1).error_on(:finance_spendable)
    end
  end

  describe '.before' do
    it 'gets the spent finances before a certain date' do
      spent_finance1.save!
      spent_finance1b.save!

      expect(SpentFinance.all.before(spent_finance1.end_date))
      .to match_array([spent_finance1])
    end
  end

  describe '.after' do
    it 'gets the spent finances after a certain date' do
      spent_finance1.save!
      spent_finance1b.save!

      expect(SpentFinance.all.after(spent_finance1b.start_date))
      .to match_array([spent_finance1b])
    end
  end

  describe '.total' do
    it 'gets the sum of the spent finance amounts' do
      spent_finance1
      spent_finance1b

      expect(SpentFinance.all.total).to eq(
        spent_finance1.amount + spent_finance1b.amount
      )
    end
  end

  describe '.prefer_official' do
    subject { SpentFinance.prefer_official }

    let!(:unofficial_tp1) do
      FactoryGirl.create(:spent_finance, official: false)
    end

    let!(:official_tp1) do
      FactoryGirl.create(:spent_finance,
        finance_spendable: unofficial_tp1.finance_spendable,
        time_period_obj: unofficial_tp1.time_period_obj,
        official: true)
    end

    let!(:unofficial_tp2) do
      FactoryGirl.create(:spent_finance,
        finance_spendable: unofficial_tp1.finance_spendable,
        official: false)
    end

    it { is_expected.to_not include(unofficial_tp1) }
    it { is_expected.to include(official_tp1) }
    it { is_expected.to include(unofficial_tp2) }
  end
end
