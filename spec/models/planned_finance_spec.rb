require 'rails_helper'
require Rails.root.join('spec', 'modules', 'time_periodable_spec')
require Rails.root.join('spec', 'validators', 'start_end_date_validator_spec')

RSpec.describe PlannedFinance do
  it_behaves_like 'TimePeriodable'
  include_examples 'StartEndDateValidator'

  let(:new_planned_finance) do
    FactoryGirl.build(:planned_finance)
  end

  let(:planned_finance1) do
    FactoryGirl.create(
      :planned_finance,
      start_date: Date.new(2014, 12, 1),
      end_date: Date.new(2014, 12, 31)
    )
  end

  let(:planned_finance1b) do
    FactoryGirl.create(
      :planned_finance,
      start_date: planned_finance1.end_date + 1,
      end_date: planned_finance1.end_date + 30,
      finance_plannable: planned_finance1.finance_plannable
    )
  end

  let(:planned_finance1c) do
    FactoryGirl.create(
      :planned_finance,
      start_date: planned_finance1b.end_date + 1,
      end_date: planned_finance1b.end_date + 30,
      finance_plannable: planned_finance1b.finance_plannable
    )
  end

  let(:planned_finance1d) do
    FactoryGirl.create(
      :planned_finance,
      start_date: planned_finance1c.end_date + 1,
      end_date: planned_finance1c.end_date + 30,
      finance_plannable: planned_finance1c.finance_plannable
    )
  end

  let(:planned_finance2) { FactoryGirl.create(:planned_finance) }

  it 'is valid with valid attributes' do
    expect(new_planned_finance).to be_valid
  end

  describe '#amount' do
    it 'is required' do
      new_planned_finance.amount = nil

      expect(new_planned_finance).to have(1).error_on(:amount)
    end
  end

  describe 'time period' do
    it 'is unique' do
      planned_finance1
      planned_finance1b.start_date = planned_finance1.start_date
      planned_finance1b.end_date = planned_finance1.end_date

      expect(planned_finance1b).to have(1).error_on(:end_date)
    end
  end

  describe '#finance_plannable' do
    it 'is required' do
      new_planned_finance.finance_plannable = nil

      expect(new_planned_finance).to have(1).error_on(:finance_plannable)
    end
  end

  describe '.year_cumulative_up_to' do
    it 'gets amount planned between beginning of the year and provided date' do
      # in 2014
      planned_finance1.save!

      # in 2015
      planned_finance1b.save!
      planned_finance1c.save!
      planned_finance1d.save!

      amount_planned = PlannedFinance.all.year_cumulative_up_to(
        planned_finance1c.end_date
      )

      expect(amount_planned).to eq(planned_finance1b.amount + planned_finance1c.amount)
    end
  end

  describe '.before' do
    it 'gets the planned finances before a certain date' do
      planned_finance1.save!
      planned_finance1b.save!

      expect(PlannedFinance.all.before(planned_finance1.end_date))
      .to match_array([planned_finance1])
    end
  end

  describe '.with_missing_finances' do
    context 'when there are planned finances for quarter 1 and quarter 3' do
      it 'adds missing finances for February and March' do
        pending 'TODO: Implement with_missing_finances for quarters'
      end
    end
  end

  describe '.after' do
    it 'gets the planned finances after a certain date' do
      planned_finance1.save!
      planned_finance1b.save!

      expect(PlannedFinance.all.after(planned_finance1b.start_date))
      .to match_array([planned_finance1b])
    end
  end

  describe '.total' do
    it 'gets the sum of the planned finance amounts' do
      planned_finance1.save!
      planned_finance1b.save!

      expect(PlannedFinance.all.total).to eq(
        planned_finance1.amount + planned_finance1b.amount
      )
    end
  end
end
