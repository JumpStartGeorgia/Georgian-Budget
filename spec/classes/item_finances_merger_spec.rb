require 'rails_helper'

RSpec.describe ItemFinancesMerger do
  let(:receiver) { create(:program) }
  let(:giver) { create(:program) }
  let(:do_merge_finances!) { ItemFinancesMerger.new(receiver, giver, finance_model).merge }

  context '' do
    let(:finance_model) { PlannedFinance }

    before do
      create_list(:planned_finance, 4, finance_plannable: giver)
    end

    it 'moves all finances to receiver' do
      do_merge_finances!

      expect(receiver.all_planned_finances.count).to eq(4)
    end
  end

  it 'updates both primary and non-primary finance amounts to be non cumulative'
  it 'updates finances in multiple years to be non cumulative'
end
