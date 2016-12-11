require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'codeable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'nameable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_spendable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_plannable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'budget_item_duplicatable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'perma_idable_spec')

RSpec.describe SpendingAgency, type: :model do
  it_behaves_like 'Codeable'
  it_behaves_like 'Nameable'
  it_behaves_like 'FinanceSpendable'
  it_behaves_like 'FinancePlannable'
  it_behaves_like 'BudgetItemDuplicatable'
  it_behaves_like 'PermaIdable'

  let(:spending_agency) { FactoryGirl.create(:spending_agency) }

  describe '#save_perma_id' do
    it 'saves computed perma_id to perma_ids' do
      spending_agency.add_code(FactoryGirl.attributes_for(:code, number: '00 1'))
      spending_agency.add_name(FactoryGirl.attributes_for(:name, text_ka: 'a b'))

      spending_agency.save_perma_id

      expect(spending_agency.perma_id).to eq(
        Digest::SHA1.hexdigest "00_1_a_b"
      )
    end
  end

  describe '#child_programs' do
    it 'returns programs that point to the agency' do
      spending_agency = FactoryGirl.create(:spending_agency)

      child1 = FactoryGirl.create(:program)
      child1.update_attribute(:parent, spending_agency)

      child2 = FactoryGirl.create(:program)
      child2.update_attribute(:parent, spending_agency)

      spending_agency.reload
      expect(spending_agency.child_programs).to include(child1, child2)
    end
  end
end
