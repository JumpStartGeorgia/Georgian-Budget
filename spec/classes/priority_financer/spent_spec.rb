require 'rails_helper'

RSpec.describe PriorityFinancer::Main do
  let(:priority) { FactoryGirl.create(:priority) }
  
  describe '#update_spent_finances' do
    context 'when priority has two programs with spent finances' do
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

      let(:program1_spent_finance1_amount) { 241 }
      let(:program2_spent_finance1_amount) { 2414 }

      let(:program1_spent_finance2_amount) { 343 }
      let(:program2_spent_finance2_amount) { nil }

      let(:program1_spent_finance3_amount) { nil }

      let(:spent_finance_time_period1) { Month.for_date(Date.new(2012, 1, 1)) }
      let(:spent_finance_time_period2) { Month.for_date(Date.new(2012, 7, 1)) }
      let(:spent_finance_time_period3) { Month.for_date(Date.new(2013, 1, 1)) }

      before :example do
        program1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          amount: program1_spent_finance1_amount,
          time_period_obj: spent_finance_time_period1))

        program2.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          amount: program2_spent_finance1_amount,
          time_period_obj: spent_finance_time_period1))

        program1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          amount: program1_spent_finance2_amount,
          time_period_obj: spent_finance_time_period2))

        program2.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          amount: program2_spent_finance2_amount,
          time_period_obj: spent_finance_time_period2))

        program1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          amount: program1_spent_finance3_amount,
          time_period_obj: spent_finance_time_period3))
      end

      it "sets priority's spent finances to program spent finance sums" do
        PriorityFinancer::Spent.new(priority).update_spent_finances

        expect(priority.spent_finances[0].time_period_obj).to eq(
          spent_finance_time_period1)

        expect(priority.spent_finances[0].amount).to eq(
          program1_spent_finance1_amount + program2_spent_finance1_amount)

        expect(priority.spent_finances[0].official).to eq(false)

        expect(priority.spent_finances[1].time_period_obj).to eq(
          spent_finance_time_period2)

        expect(priority.spent_finances[1].amount).to eq(
          program1_spent_finance2_amount)

        expect(priority.spent_finances[1].official).to eq(false)

        expect(priority.spent_finances[2].time_period_obj).to eq(
          spent_finance_time_period3)

        expect(priority.spent_finances[2].amount).to eq(
          program1_spent_finance3_amount)

        expect(priority.spent_finances[2].official).to eq(false)
      end
    end
  end
end
