require 'rails_helper'
require Rails.root.join('spec', 'validators', 'start_end_date_validator_spec')

RSpec.describe SpentFinance do
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
      start_date: spent_finance1.end_date + 1,
      end_date: spent_finance1.end_date + 30,
      finance_spendable: spent_finance1.finance_spendable
    )
  end

  let(:spent_finance1c) do
    FactoryGirl.create(
      :spent_finance,
      start_date: spent_finance1b.end_date + 1,
      end_date: spent_finance1b.end_date + 30,
      finance_spendable: spent_finance1b.finance_spendable
    )
  end

  let(:spent_finance1d) do
    FactoryGirl.create(
      :spent_finance,
      start_date: spent_finance1c.end_date + 1,
      end_date: spent_finance1c.end_date + 30,
      finance_spendable: spent_finance1c.finance_spendable
    )
  end

  it 'is valid with valid attributes' do
    expect(new_spent_finance).to be_valid
  end

  describe '#amount' do
    it 'is required' do
      new_spent_finance.amount = nil

      expect(new_spent_finance).to have(1).error_on(:amount)
    end
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

  describe '.year_cumulative_up_to' do
    it 'gets amount spent between beginning of the year and provided date' do
      # in 2014
      spent_finance1.save!

      # in 2015
      spent_finance1b.save!
      spent_finance1c.save!
      spent_finance1d.save!

      amount_spent = SpentFinance.all.year_cumulative_up_to(
        spent_finance1c.end_date
      )



      expect(amount_spent).to eq(spent_finance1b.amount + spent_finance1c.amount)
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
      spent_finance1.save!
      spent_finance1b.save!

      expect(SpentFinance.all.total).to eq(
        spent_finance1.amount + spent_finance1b.amount
      )
    end
  end
end
