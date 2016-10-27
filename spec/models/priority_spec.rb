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
          SpentFinance.create(
            finance_spendable: program1,
            amount: program1_spent_finance1_amount,
            time_period: spent_finance_time_period1)

          SpentFinance.create(
            finance_spendable: program2,
            amount: program2_spent_finance1_amount,
            time_period: spent_finance_time_period1)

          SpentFinance.create(
            finance_spendable: program1,
            amount: program1_spent_finance2_amount,
            time_period: spent_finance_time_period2)
        end

        it "sets priority's first spent finance to program spent finance sums" do
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

      it "sets priority's planned finances to program planned finance sums"
    end
  end
end
