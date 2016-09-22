require 'rails_helper'

RSpec.shared_examples_for 'FinancePlannable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:finance_plannable1) { FactoryGirl.create(described_class_sym) }

  let(:planned_finance1) do
    FactoryGirl.create(
      :planned_finance,
      finance_plannable: finance_plannable1
    )
  end

  let(:planned_finance1b) do
    FactoryGirl.create(
      :planned_finance,
      finance_plannable: finance_plannable1
    )
  end

  describe '#destroy' do
    it 'should destroy associated planned_finances' do
      finance_plannable1.save!
      planned_finance1.save!
      planned_finance1b.save!

      finance_plannable1.destroy

      expect(PlannedFinance.exists?(planned_finance1.id)).to eq(false)
      expect(PlannedFinance.exists?(planned_finance1b.id)).to eq(false)
    end
  end

  describe '#planned_finances' do
    it 'gets all planned finances for the finance_plannable' do
      expect(finance_plannable1.planned_finances).to match_array([planned_finance1, planned_finance1b])
    end

    it 'are ordered by start date' do
      planned_finance1
      planned_finance1b.start_date = planned_finance1.start_date + 1
      planned_finance1b.save!

      expect(finance_plannable1.planned_finances).to eq(
        [planned_finance1, planned_finance1b]
      )
    end
  end
end
