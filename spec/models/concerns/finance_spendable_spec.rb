require 'rails_helper'

RSpec.shared_examples_for 'FinanceSpendable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:finance_spendable1) { FactoryGirl.create(described_class_sym) }

  let(:spent_finance1) do
    FactoryGirl.create(
      :spent_finance,
      finance_spendable: finance_spendable1
    )
  end

  let(:spent_finance1b) do
    FactoryGirl.create(
      :spent_finance,
      finance_spendable: finance_spendable1
    )
  end

  describe '#spent_finances' do
    it 'gets all spent finances for the finance_spendable' do
      expect(finance_spendable1.spent_finances).to match_array([spent_finance1, spent_finance1b])
    end
  end
end
