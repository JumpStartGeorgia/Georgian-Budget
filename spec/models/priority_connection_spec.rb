require 'rails_helper'
require Rails.root.join('spec', 'validators', 'start_end_date_validator_spec')

RSpec.describe PriorityConnection, type: :model do
  include_examples 'StartEndDateValidator'

  let(:new_priority_connection) { FactoryGirl.create(:priority_connection) }

  describe '#priority_connectable' do
    it 'is required' do
      new_priority_connection.priority_connectable = nil
      expect(new_priority_connection).to have(1).error_on(:priority_connectable)
    end
  end

  describe '#priority' do
    it 'is required' do
      new_priority_connection.priority = nil
      expect(new_priority_connection).to have(1).error_on(:priority)
    end
  end

  describe '#time_period_obj=' do
    it "sets start date to time period's start date" do
      new_priority_connection.time_period_obj = Quarter.for_date(Date.new(2011, 2, 2))

      expect(new_priority_connection.start_date).to eq(Date.new(2011, 1, 1))
    end

    it "sets end date to time period's end date" do
      new_priority_connection.time_period_obj = Quarter.for_date(Date.new(2011, 2, 2))

      expect(new_priority_connection.end_date).to eq(Date.new(2011, 3, 31))
    end
  end

  describe '.direct' do
    it 'returns only priority connections marked direct' do
      FactoryGirl.create_list(:priority_connection, 2, direct: true)
      FactoryGirl.create(:priority_connection, direct: false)

      expect(PriorityConnection.direct.length).to eq(2)
    end
  end
end
