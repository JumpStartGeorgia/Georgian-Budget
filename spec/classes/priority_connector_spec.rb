require 'rails_helper'

RSpec.describe PriorityConnector do
  describe '#connect' do
    it 'adds a priority connection to the priority connectable' do
      priority_connectable = create(:program)

      PriorityConnector.new(priority_connectable).connect(
        attributes_with_foreign_keys(:priority_connection)
      )

      expect(priority_connectable.priority_connections.length).to eq(1)
    end
  end
end
