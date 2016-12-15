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
end
