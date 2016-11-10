require 'rails_helper'
require Rails.root.join('spec', 'validators', 'start_end_date_validator_spec')
require Rails.root.join('spec', 'models', 'concerns', 'time_periodable_spec')

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
      start_date: planned_finance1.time_period.next.start_date,
      end_date: planned_finance1.time_period.next.end_date,
      finance_plannable: planned_finance1.finance_plannable
    )
  end

  let(:planned_finance1c) do
    FactoryGirl.create(
      :planned_finance,
      start_date: planned_finance1b.time_period.next.start_date,
      end_date: planned_finance1b.time_period.next.end_date,
      finance_plannable: planned_finance1b.finance_plannable
    )
  end

  let(:planned_finance1d) do
    FactoryGirl.create(
      :planned_finance,
      start_date: planned_finance1c.time_period.next.start_date,
      end_date: planned_finance1c.time_period.next.end_date,
      finance_plannable: planned_finance1c.finance_plannable
    )
  end

  let(:planned_finance2) { FactoryGirl.create(:planned_finance) }

  it 'is valid with valid attributes' do
    expect(new_planned_finance).to be_valid
  end

  describe '#announce_date' do
    it 'is required' do
      planned_finance1.announce_date = nil

      expect(planned_finance1).to have(1).error_on(:announce_date)
    end

    it 'is unique for same finance_plannable, start_date, and end_date' do
      planned_finance1
      planned_finance1b.start_date = planned_finance1.start_date
      planned_finance1b.end_date = planned_finance1.end_date
      planned_finance1b.announce_date = planned_finance1.announce_date

      expect(planned_finance1b).to have(1).error_on(:announce_date)
    end
  end

  describe '#finance_plannable' do
    it 'is required' do
      new_planned_finance.finance_plannable = nil

      expect(new_planned_finance).to have(1).error_on(:finance_plannable)
    end
  end

  describe '==' do
    context 'when two planned finances' do
      before :each do
        planned_finance1b.update_attributes(
          finance_plannable: planned_finance1.finance_plannable,
          start_date: planned_finance1.start_date,
          end_date: planned_finance1.end_date,
          # announce date must be different, otherwise validation won't pass
          announce_date: planned_finance1.announce_date + 1,
          amount: planned_finance1.amount
        )
      end

      context 'have different finance plannable' do
        it 'returns false' do
          planned_finance1b.update_attributes(
            announce_date: planned_finance1.announce_date,
            finance_plannable: FactoryGirl.create(:program)
          )

          planned_finance1b.reload

          expect(planned_finance1 == planned_finance1b).to eq(false)
        end
      end

      context 'have different start date' do
        it 'returns false' do
          planned_finance1b.update_attributes(
            announce_date: planned_finance1.announce_date,
            time_period: planned_finance1.time_period.next
          )

          planned_finance1b.reload

          expect(planned_finance1 == planned_finance1b).to eq(false)
        end
      end

      context 'have different announce date' do
        context 'and amounts are the same' do
          it 'returns true' do
            planned_finance1b.reload

            expect(planned_finance1 == planned_finance1b).to eq(true)
          end
        end

        context 'and amounts are different' do
          it 'returns false' do
            planned_finance1b.update_attributes(
              amount: planned_finance1.amount + 1
            )

            planned_finance1b.reload

            expect(planned_finance1 == planned_finance1b).to eq(false)
          end
        end
      end
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
