require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'codeable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'nameable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_spendable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_plannable_spec')

RSpec.describe Priority, type: :model do
  it_behaves_like 'Codeable'
  it_behaves_like 'Nameable'
  it_behaves_like 'FinanceSpendable'
  it_behaves_like 'FinancePlannable'

  let(:priority) { FactoryGirl.create(:priority) }

  describe '#update_finances' do
    context 'when priority has no programs' do
      it 'adds no spent finances to priority' do
        priority.update_finances

        expect(priority.spent_finances.length).to eq(0)
      end

      it 'adds no planned finances to priority' do
        priority.update_finances

        expect(priority.planned_finances.length).to eq(0)
      end
    end

    context 'when priority has two programs' do
      let(:program1) do
        FactoryGirl.create(
          :program,
          code: '01 01',
          priority: priority)
      end

      let(:program2) do
        FactoryGirl.create(
          :program,
          code: '01 02',
          priority: priority)
      end

      context 'with spent finances' do
        let(:program1_spent_finance1_amount) { 241 }
        let(:program1_spent_finance2_amount) { 343 }

        let(:program2_spent_finance1_amount) { 2414 }

        let(:spent_finance_time_period1) { Month.for_date(Date.new(2012, 1, 1)) }
        let(:spent_finance_time_period2) { Month.for_date(Date.new(2012, 7, 1)) }

        before :example do
          program1.add_spent_finance(
            amount: program1_spent_finance1_amount,
            time_period: spent_finance_time_period1)

          program2.add_spent_finance(
            amount: program2_spent_finance1_amount,
            time_period: spent_finance_time_period1)

          program1.add_spent_finance(
            amount: program1_spent_finance2_amount,
            time_period: spent_finance_time_period2)
        end

        it "sets priority's spent finances to program spent finance sums" do
          priority.update_finances

          expect(priority.spent_finances[0].time_period).to eq(
            spent_finance_time_period1)

          expect(priority.spent_finances[0].amount).to eq(
            program1_spent_finance1_amount + program2_spent_finance1_amount)

          expect(priority.spent_finances[1].time_period).to eq(
            spent_finance_time_period2)

          expect(priority.spent_finances[1].amount).to eq(
            program1_spent_finance2_amount)
        end
      end

      context 'with planned finances' do
        let(:planned_finance_time_period1) { Quarter.for_date(Date.new(2012, 1, 1)) }

        let(:planned_finance_q1_jan) { priority.all_planned_finances[0] }
        let(:planned_finance_announce_date1a) { Date.new(2012, 1, 1) }
        let(:program1_planned_finance1a_amount) { 434559 }

        let(:planned_finance_q1_feb) { priority.all_planned_finances[1] }
        let(:planned_finance_announce_date1b) { Date.new(2012, 2, 1) }
        let(:program1_planned_finance1b_amount) { 343 }
        let(:program2_planned_finance1b_amount) { 2414 }

        let(:planned_finance_q1_march) { priority.all_planned_finances[2] }
        let(:planned_finance_announce_date1c) { Date.new(2012, 3, 1) }
        let(:program2_planned_finance1c_amount) { 23111 }

        let(:planned_finance_time_period2) { Quarter.for_date(Date.new(2012, 10, 1)) }

        let(:planned_finance_q4_oct) { priority.all_planned_finances[3] }
        let(:planned_finance_announce_date2) { Date.new(2012, 10, 1) }
        let(:program1_planned_finance2_amount) { 2222 }

        before :each do
          program1.add_planned_finance(
            time_period: planned_finance_time_period1,
            announce_date: planned_finance_announce_date1a,
            amount: program1_planned_finance1a_amount)

          program1.add_planned_finance(
            time_period: planned_finance_time_period1,
            announce_date: planned_finance_announce_date1b,
            amount: program1_planned_finance1b_amount)

          program2.add_planned_finance(
            time_period: planned_finance_time_period1,
            announce_date: planned_finance_announce_date1b,
            amount: program2_planned_finance1b_amount)

          program2.add_planned_finance(
            time_period: planned_finance_time_period1,
            announce_date: planned_finance_announce_date1c,
            amount: program2_planned_finance1c_amount)

          program1.add_planned_finance(
            time_period: planned_finance_time_period2,
            announce_date: planned_finance_announce_date2,
            amount: program1_planned_finance2_amount)
        end

        it 'creates planned finance without at the time unannounced program plans' do
          priority.update_finances

          expect(planned_finance_q1_jan.amount).to eq(
            program1_planned_finance1a_amount)
        end

        it 'creates planned finance with program plans announced on same date when available' do
          priority.update_finances

          expect(planned_finance_q1_feb.amount).to eq(
            program1_planned_finance1b_amount +
            program2_planned_finance1b_amount)
        end

        it 'creates planned finance with most recent program plans for time period' do
          priority.update_finances

          expect(planned_finance_q1_march.amount).to eq(
            program1_planned_finance1b_amount +
            program2_planned_finance1c_amount)
        end

        it 'creates planned finance from only one program if one is available' do
          priority.update_finances

          expect(planned_finance_q4_oct.amount).to eq(
            program1_planned_finance2_amount)
        end
      end
    end
  end
end
