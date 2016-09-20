require 'rails_helper'
require Rails.root.join('spec', 'modules', 'time_periodable_spec')
require Rails.root.join('spec', 'validators', 'start_end_date_validator_spec')

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

  let(:spent_finance2) { FactoryGirl.create(:spent_finance) }

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

  describe '.with_missing_finances' do
    context 'when there are two monthly spent finances in January and April' do
      it 'adds missing finances for February and March' do
        spent_finance1.start_date = Date.new(2015, 1, 1)
        spent_finance1.end_date = Date.new(2015, 1, 31)
        spent_finance1.save

        spent_finance1b.start_date = Date.new(2015, 4, 1)
        spent_finance1b.end_date = Date.new(2015, 4, 30)
        spent_finance1b.save

        spent_finance2

        finances_with_missing = spent_finance1.finance_spendable.reload.spent_finances.with_missing_finances
        expect(finances_with_missing.length).to eq(4)

        expect(finances_with_missing).to include(spent_finance1)
        expect(finances_with_missing).to include(spent_finance1b)

        february_missing_finance = finances_with_missing.find do |finance|
          finance.start_date == Date.new(2015, 2, 1)
        end

        expect(february_missing_finance).to_not eq(nil)
        expect(february_missing_finance.end_date).to eq(Date.new(2015, 2, 28))
        expect(february_missing_finance.class).to eq(MissingFinance)

        march_missing_finance = finances_with_missing.find do |finance|
          finance.start_date == Date.new(2015, 3, 1)
        end

        expect(march_missing_finance).to_not eq(nil)
        expect(march_missing_finance.end_date).to eq(Date.new(2015, 3, 31))
        expect(march_missing_finance.class).to eq(MissingFinance)
      end
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
