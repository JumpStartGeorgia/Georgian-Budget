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
      start_date: spent_finance1.time_period.next.start_date,
      end_date: spent_finance1.time_period.next.end_date,
      finance_spendable: spent_finance1.finance_spendable
    )
  end

  let(:spent_finance1c) do
    FactoryGirl.create(
      :spent_finance,
      start_date: spent_finance1b.time_period.next.start_date,
      end_date: spent_finance1b.time_period.next.end_date,
      finance_spendable: spent_finance1b.finance_spendable
    )
  end

  let(:spent_finance1d) do
    FactoryGirl.create(
      :spent_finance,
      start_date: spent_finance1c.time_period.next.start_date,
      end_date: spent_finance1c.time_period.next.end_date,
      finance_spendable: spent_finance1c.finance_spendable
    )
  end

  let(:spent_finance2) { FactoryGirl.create(:spent_finance) }

  it 'is valid with valid attributes' do
    expect(new_spent_finance).to be_valid
  end

  describe 'time period' do
    it 'is unique' do
      spent_finance1
      spent_finance1b.start_date = spent_finance1.start_date
      spent_finance1b.end_date = spent_finance1.end_date

      expect(spent_finance1b).to have(1).error_on(:end_date)
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
end
