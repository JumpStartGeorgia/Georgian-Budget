require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'nameable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_spendable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_plannable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'perma_idable_spec')

RSpec.describe Priority, type: :model do
  it_behaves_like 'Nameable'
  it_behaves_like 'FinanceSpendable'
  it_behaves_like 'FinancePlannable'
  it_behaves_like 'PermaIdable'

  let(:priority) { FactoryGirl.create(:priority) }

  describe '#connections' do
    it 'returns all priority connections attached to this priority' do
      connections = create_list(:priority_connection, 2, priority: priority)
      create_list(:priority_connection, 3)

      expect(priority.connections.map(&:id))
      .to contain_exactly(*connections.map(&:id))
    end
  end

  describe '#save_perma_id' do
    it 'saves computed perma_id to perma_ids' do
      priority.add_name(FactoryGirl.attributes_for(:name, text_ka: 'a b'))
      priority.save_perma_id

      expect(priority.perma_id).to eq(
        Digest::SHA1.hexdigest "a_b"
      )
    end
  end

  describe '#all_programs' do
    it 'gets all programs connected to priority' do
      programA = create(:program)
      programAA = create(:program)
      create(:program)

      create(:priority_connection,
        priority: priority,
        priority_connectable: programA,
        direct: true)

      create(:priority_connection,
        priority: priority,
        priority_connectable: programA,
        direct: false)

      create(:priority_connection,
        priority: priority,
        priority_connectable: programAA,
        direct: true)

      expect(priority.all_programs).to contain_exactly(programA, programAA)
    end
  end

  describe '#child_programs' do
    it 'gets all programs connected to priority without a parent program' do
      programA = create(:program)
      programAA = create(:program, parent_program: programA)
      create(:program)

      create(:priority_connection,
      priority: priority,
      priority_connectable: programA,
      direct: true)

      create(:priority_connection,
      priority: priority,
      priority_connectable: programA,
      direct: false)

      create(:priority_connection,
      priority: priority,
      priority_connectable: programAA,
      direct: true)

      expect(priority.child_programs).to contain_exactly(programA)
    end
  end

  describe '#spending_agencies' do
    it 'gets all agencies connected to priority' do
      agency = create(:spending_agency)
      create(:spending_agency)

      create(:priority_connection,
      priority: priority,
      priority_connectable: agency,
      direct: true)

      create(:priority_connection,
      priority: priority,
      priority_connectable: agency,
      direct: false)

      expect(priority.spending_agencies).to contain_exactly(agency)
    end
  end
end
