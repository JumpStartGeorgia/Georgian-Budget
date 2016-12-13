require 'rails_helper'

RSpec.describe PriorityFinancer::Main do
  let(:priority) { FactoryGirl.create(:priority) }

  describe '#update_finances' do
    context 'when priority has no programs' do
      it 'adds no spent finances to priority' do
        PriorityFinancer::Main.new(priority).update_finances

        expect(priority.spent_finances.length).to eq(0)
      end

      it 'adds no planned finances to priority' do
        PriorityFinancer::Main.new(priority).update_finances

        expect(priority.planned_finances.length).to eq(0)
      end
    end
  end
end
