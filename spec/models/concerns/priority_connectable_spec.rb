require 'rails_helper'

RSpec.shared_examples_for 'PriorityConnectable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }
  let(:priority_connectable) { FactoryGirl.create(described_class_sym) }

  describe '#direct_priority_connections' do
    it 'gets direct priority connections' do
      FactoryGirl.create_list(
        :priority_connection,
        2,
        direct: true,
        priority_connectable: priority_connectable)

      FactoryGirl.create(
        :priority_connection,
        direct: false,
        priority_connectable: priority_connectable)

      expect(priority_connectable.direct_priority_connections.length).to eq(2)
    end
  end
end
