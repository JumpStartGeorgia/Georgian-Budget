require 'rails_helper'

RSpec.describe ItemFinancesMerger do
  describe '#merge' do
    it 'moves all finances to receiver' do
      receiver = create(:program)
      program = create(:program)
      create_list(:planned_finance, 4, finance_plannable: program)
      ItemFinancesMerger.new(receiver, program.all_planned_finances).merge

      expect(receiver.all_planned_finances.count).to eq(4)
    end
  end
end
