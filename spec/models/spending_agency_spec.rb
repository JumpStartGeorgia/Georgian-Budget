require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'codeable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'nameable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_spendable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_plannable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'budget_item_duplicatable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'perma_idable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'priority_connectable_spec')

RSpec.describe SpendingAgency, type: :model do
  it_behaves_like 'Codeable'
  it_behaves_like 'Nameable'
  it_behaves_like 'FinanceSpendable'
  it_behaves_like 'FinancePlannable'
  it_behaves_like 'BudgetItemDuplicatable'
  it_behaves_like 'PermaIdable'
  it_behaves_like 'PriorityConnectable'

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
    it 'returns top-level programs that point to the agency' do
      spending_agency = FactoryGirl.create(:spending_agency)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 00'))

      child1 = FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 02'))

      child2 = FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 045'))

      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 045 01'))

      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '02 01'))

      spending_agency.reload
      expect(spending_agency.child_programs).to contain_exactly(child1, child2)
    end
  end

  describe '#all_programs' do
    it 'returns all programs that point to the agency' do
      spending_agency = FactoryGirl.create(:spending_agency)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 00'))

      child1 = FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 02'))

      child2 = FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 045'))

      grandchild = FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 045 01'))

      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '02 01'))

      spending_agency.reload
      expect(spending_agency.all_programs)
      .to contain_exactly(child1, child2, grandchild)
    end
  end

  describe '#ancestors' do
    it 'returns empty array' do
      expect(spending_agency.ancestors).to eq([])
    end
  end

  describe '#priorities' do
    it 'returns all connected priorities' do
      agency = create(:spending_agency)
      priority1 = create(:priority)
      priority2 = create(:priority)
      create(:priority)

      create(:priority_connection,
        priority_connectable: agency,
        priority: priority1)

      create(:priority_connection,
        priority_connectable: agency,
        priority: priority1)

      create(:priority_connection,
        priority_connectable: agency,
        priority: priority2)

      expect(agency.priorities).to contain_exactly(priority1, priority2)
    end
  end
end
