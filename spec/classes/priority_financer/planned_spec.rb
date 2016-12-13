require 'rails_helper'

RSpec.describe PriorityFinancer::Planned do
  let(:priority) { FactoryGirl.create(:priority) }

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

  describe '#update_planned_finances' do
    context 'when priority has two programs with planned finances' do
      context 'and four planned finances are in same quarter' do
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

        before :example do
          program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
            time_period_obj: planned_finance_time_period1,
            announce_date: planned_finance_announce_date1a,
            amount: program1_planned_finance1a_amount))

          program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
            time_period_obj: planned_finance_time_period1,
            announce_date: planned_finance_announce_date1b,
            amount: program1_planned_finance1b_amount))

          program2.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
            time_period_obj: planned_finance_time_period1,
            announce_date: planned_finance_announce_date1b,
            amount: program2_planned_finance1b_amount))

          program2.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
            time_period_obj: planned_finance_time_period1,
            announce_date: planned_finance_announce_date1c,
            amount: program2_planned_finance1c_amount))
        end

        it 'creates planned finance without at the time unannounced program plans' do
          PriorityFinancer::Planned.new(priority).update_planned_finances

          expect(planned_finance_q1_jan.amount).to eq(
            program1_planned_finance1a_amount)

          expect(planned_finance_q1_jan.official).to eq(false)
        end

        it 'creates planned finance with program plans announced on same date when available' do
          PriorityFinancer::Planned.new(priority).update_planned_finances

          expect(planned_finance_q1_feb.amount).to eq(
            program1_planned_finance1b_amount +
            program2_planned_finance1b_amount)

          expect(planned_finance_q1_feb.official).to eq(false)
        end

        it 'creates planned finance with most recent program plans for time period' do
          PriorityFinancer::Planned.new(priority).update_planned_finances

          expect(planned_finance_q1_march.amount).to eq(
            program1_planned_finance1b_amount +
            program2_planned_finance1c_amount)

          expect(planned_finance_q1_march.official).to eq(false)
        end
      end

      context 'when two programs have planned finances for quarter but one has nil amount' do
        let(:planned_finance_time_period2) { Quarter.for_date(Date.new(2012, 10, 1)) }

        let(:planned_finance_announce_date2) { Date.new(2012, 10, 1) }
        let(:program1_planned_finance2_amount) { 2222 }
        let(:program2_planned_finance2_amount) { nil }

        before :each do
          program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
            time_period_obj: planned_finance_time_period2,
            announce_date: planned_finance_announce_date2,
            amount: program1_planned_finance2_amount))

          program2.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
            time_period_obj: planned_finance_time_period2,
            announce_date: planned_finance_announce_date2,
            amount: program2_planned_finance2_amount))
        end

        it 'creates planned finance for quarter from non-nil finance' do
          PriorityFinancer::Planned.new(priority).update_planned_finances

          expect(priority.all_planned_finances[0].amount).to eq(
            program1_planned_finance2_amount)

          expect(priority.all_planned_finances[0].official).to eq(false)
        end
      end

      context 'when only one program has planned finance for quarter and amount is nil' do
        let(:q3) { Quarter.for_date(q3_august_announce_date) }

        let(:q3_august_announce_date) { Date.new(2012, 8, 1) }
        let(:program1_planned_finance_q3_august_amount) { nil }

        before :example do
          program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
            time_period_obj: q3,
            announce_date: q3_august_announce_date,
            amount: program1_planned_finance_q3_august_amount))
        end

        it 'creates planned finance with nil amount' do
          PriorityFinancer::Planned.new(priority).update_planned_finances

          expect(priority.all_planned_finances[0].amount).to eq(
            program1_planned_finance_q3_august_amount)

          expect(priority.all_planned_finances[0].official).to eq(false)
        end
      end
    end
  end
end
