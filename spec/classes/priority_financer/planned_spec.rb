require 'rails_helper'

RSpec.describe PriorityFinancer::Planned do
  let(:jan_2012) { Month.for_date(Date.new(2012, 1, 1)) }
  let(:priority) { FactoryGirl.create(:priority) }

  let(:do_update_planned_finances!) do
    PriorityFinancer::Planned.new(priority).update_from(planned_finances)
  end

  describe '#update_from' do
    context '' do
      let!(:plan1) do
        create(:planned_finance, time_period_obj: Year.new(2011))
      end

      let!(:plan2) do
        create(:planned_finance, time_period_obj: Year.new(2012))
      end

      let(:planned_finances) do
        PlannedFinance.where(id: [plan1, plan2])
      end

      it 'saves all plans as unofficial' do
        do_update_planned_finances!

        expect(priority.all_planned_finances.unofficial.length).to eq(2)
      end
    end

    context 'when there are multiple announced plans in same month' do
      let(:program) { create(:program) }

      let!(:program_plan_announced_jan) do
        create(:planned_finance,
          finance_plannable: program,
          time_period_obj: jan_2012,
          announce_date: Date.new(2012, 1, 1))
      end

      let!(:program_plan_announced_feb) do
        create(:planned_finance,
          finance_plannable: program,
          time_period_obj: jan_2012,
          announce_date: Date.new(2012, 2, 1))
      end

      let(:agency) { create(:spending_agency) }

      let!(:agency_plan_announced_feb) do
        create(:planned_finance,
          finance_plannable: agency,
          time_period_obj: jan_2012,
          announce_date: Date.new(2012, 2, 1))
      end

      let!(:agency_plan_announced_march) do
        create(:planned_finance,
          finance_plannable: agency,
          time_period_obj: jan_2012,
          announce_date: Date.new(2012, 3, 1))
      end

      let(:planned_finances) do
        PlannedFinance.where(id: [
          program_plan_announced_jan,
          program_plan_announced_feb,
          agency_plan_announced_feb,
          agency_plan_announced_march
        ])
      end

      before do
        do_update_planned_finances!
      end

      it 'saves three plans for month' do
        expect(priority.all_planned_finances.length).to eq(3)
      end

      it 'saves plan to priority without at the time unannounced plans' do
        plan = priority.all_planned_finances
        .with_time_period(jan_2012).announced(Date.new(2012, 1, 1)).first

        expect(plan.amount).to eq(program_plan_announced_jan.amount)
      end

      it 'saves plan to priority that is sum of plans announced on same date' do
        plan = priority.all_planned_finances
        .with_time_period(jan_2012).announced(Date.new(2012, 2, 1)).first

        expect(plan.amount).to eq(
          program_plan_announced_feb.amount +
          agency_plan_announced_feb.amount
        )
      end

      it 'saves plan to priority that is sum of most recent plans' do
        plan = priority.all_planned_finances
        .with_time_period(jan_2012).announced(Date.new(2012, 3, 1)).first

        expect(plan.amount).to eq(
          program_plan_announced_feb.amount +
          agency_plan_announced_march.amount
        )
      end
    end

    context 'when there are two plans with different time periods' do
      let!(:plan1) { create(:planned_finance, time_period_obj: Year.new(2011)) }
      let!(:plan2) { create(:planned_finance, time_period_obj: Year.new(2012)) }

      let(:planned_finances) do
        PlannedFinance.where(id: [plan1, plan2])
      end

      before do
        do_update_planned_finances!
      end

      it 'saves two plans to priority' do
        expect(priority.all_planned_finances.map(&:amount))
        .to contain_exactly(plan1.amount, plan2.amount)
      end
    end

    context 'when there are two plans with same dates and nil amounts' do
      let(:planned_finances) do
        PlannedFinance.where(id: create_list(
          :planned_finance,
          2,
          time_period_obj: Year.new(2012),
          announce_date: Date.new(2013, 1, 1),
          amount: nil)
        )
      end

      before do
        do_update_planned_finances!
      end

      it 'saves plan to priority with those dates and nil amount' do
        expect(priority.all_planned_finances.map(&:amount))
        .to contain_exactly(nil)
      end
    end

    context 'when there are three plans with same dates and one has nil amount' do
      let!(:non_nil_plans) do
        create_list(:planned_finance,
          2,
          time_period_obj: Year.new(1492),
          announce_date: Date.new(1492, 1, 1))
      end

      let!(:nil_plan) do
        create(:planned_finance,
          time_period_obj: Year.new(1492),
          announce_date: Date.new(1492, 1, 1),
          amount: nil)
      end

      let(:planned_finances) do
        PlannedFinance.where(id: [*non_nil_plans, nil_plan])
      end

      before do
        do_update_planned_finances!
      end

      it 'saves plan to priority with those dates and sum of non-nil amounts' do
        expect(priority.all_planned_finances.map(&:amount))
        .to contain_exactly(non_nil_plans.map(&:amount).sum)
      end
    end
  end

  # describe '#update_planned_finances' do
  #   context 'when priority has two programs with planned finances' do
  #     context 'and four planned finances are in same quarter' do
  #       let(:planned_finance_time_period1) { Quarter.for_date(Date.new(2012, 1, 1)) }
  #
  #       let(:planned_finance_q1_jan) { priority.all_planned_finances[0] }
  #       let(:planned_finance_announce_date1a) { Date.new(2012, 1, 1) }
  #       let(:program1_planned_finance1a_amount) { 434559 }
  #
  #       let(:planned_finance_q1_feb) { priority.all_planned_finances[1] }
  #       let(:planned_finance_announce_date1b) { Date.new(2012, 2, 1) }
  #       let(:program1_planned_finance1b_amount) { 343 }
  #       let(:program2_planned_finance1b_amount) { 2414 }
  #
  #       let(:planned_finance_q1_march) { priority.all_planned_finances[2] }
  #       let(:planned_finance_announce_date1c) { Date.new(2012, 3, 1) }
  #       let(:program2_planned_finance1c_amount) { 23111 }
  #
  #       before :example do
  #         program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
  #           time_period_obj: planned_finance_time_period1,
  #           announce_date: planned_finance_announce_date1a,
  #           amount: program1_planned_finance1a_amount))
  #
  #         program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
  #           time_period_obj: planned_finance_time_period1,
  #           announce_date: planned_finance_announce_date1b,
  #           amount: program1_planned_finance1b_amount))
  #
  #         program2.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
  #           time_period_obj: planned_finance_time_period1,
  #           announce_date: planned_finance_announce_date1b,
  #           amount: program2_planned_finance1b_amount))
  #
  #         program2.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
  #           time_period_obj: planned_finance_time_period1,
  #           announce_date: planned_finance_announce_date1c,
  #           amount: program2_planned_finance1c_amount))
  #       end
  #
  #       it 'creates planned finance without at the time unannounced program plans' do
  #         PriorityFinancer::Planned.new(priority).update_planned_finances
  #
  #         expect(planned_finance_q1_jan.amount).to eq(
  #           program1_planned_finance1a_amount)
  #
  #         expect(planned_finance_q1_jan.official).to eq(false)
  #       end
  #
  #       it 'creates planned finance with program plans announced on same date when available' do
  #         PriorityFinancer::Planned.new(priority).update_planned_finances
  #
  #         expect(planned_finance_q1_feb.amount).to eq(
  #           program1_planned_finance1b_amount +
  #           program2_planned_finance1b_amount)
  #
  #         expect(planned_finance_q1_feb.official).to eq(false)
  #       end
  #
  #       it 'creates planned finance with most recent program plans for time period' do
  #         PriorityFinancer::Planned.new(priority).update_planned_finances
  #
  #         expect(planned_finance_q1_march.amount).to eq(
  #           program1_planned_finance1b_amount +
  #           program2_planned_finance1c_amount)
  #
  #         expect(planned_finance_q1_march.official).to eq(false)
  #       end
  #     end
  #
  #     context 'when two programs have planned finances for quarter but one has nil amount' do
  #       let(:planned_finance_time_period2) { Quarter.for_date(Date.new(2012, 10, 1)) }
  #
  #       let(:planned_finance_announce_date2) { Date.new(2012, 10, 1) }
  #       let(:program1_planned_finance2_amount) { 2222 }
  #       let(:program2_planned_finance2_amount) { nil }
  #
  #       before :each do
  #         program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
  #           time_period_obj: planned_finance_time_period2,
  #           announce_date: planned_finance_announce_date2,
  #           amount: program1_planned_finance2_amount))
  #
  #         program2.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
  #           time_period_obj: planned_finance_time_period2,
  #           announce_date: planned_finance_announce_date2,
  #           amount: program2_planned_finance2_amount))
  #       end
  #
  #       it 'creates planned finance for quarter from non-nil finance' do
  #         PriorityFinancer::Planned.new(priority).update_planned_finances
  #
  #         expect(priority.all_planned_finances[0].amount).to eq(
  #           program1_planned_finance2_amount)
  #
  #         expect(priority.all_planned_finances[0].official).to eq(false)
  #       end
  #     end
  #
  #     context 'when only one program has planned finance for quarter and amount is nil' do
  #       let(:q3) { Quarter.for_date(q3_august_announce_date) }
  #
  #       let(:q3_august_announce_date) { Date.new(2012, 8, 1) }
  #       let(:program1_planned_finance_q3_august_amount) { nil }
  #
  #       before :example do
  #         program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
  #           time_period_obj: q3,
  #           announce_date: q3_august_announce_date,
  #           amount: program1_planned_finance_q3_august_amount))
  #       end
  #
  #       it 'creates planned finance with nil amount' do
  #         PriorityFinancer::Planned.new(priority).update_planned_finances
  #
  #         expect(priority.all_planned_finances[0].amount).to eq(
  #           program1_planned_finance_q3_august_amount)
  #
  #         expect(priority.all_planned_finances[0].official).to eq(false)
  #       end
  #     end
  #   end
  # end
end
