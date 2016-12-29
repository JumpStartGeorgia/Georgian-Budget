require 'rails_helper'

RSpec.describe ItemFinancesMerger do
  let(:receiver) { create(:program) }
  let(:do_merge_finances!) { ItemFinancesMerger.new(receiver, finances).merge }

  context '' do
    let(:program) do
      create(:program, all_planned_finances: create_list(:planned_finance, 4))
    end

    let(:finances) { program.all_planned_finances }

    it 'moves all finances to receiver' do
      do_merge_finances!

      expect(receiver.all_planned_finances.count).to eq(4)
    end
  end
end
