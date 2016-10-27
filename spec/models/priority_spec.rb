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

  describe '#update_finances' do
    context 'when priority has no programs' do
      it 'adds no planned finances to priority'
      it 'adds no spent finances to priority'
    end

    context 'when priority has two programs' do
      it "sets priority's planned finances to program planned finance sums" do
        
      end

      it "sets priority's spent finances to program spent finance sums" do

      end
    end
  end
end
