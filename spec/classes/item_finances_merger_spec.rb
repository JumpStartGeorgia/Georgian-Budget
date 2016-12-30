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

  context 'when giver has two plans preceded by receiver plan' do
    let(:finance_model) { PlannedFinance }

    let!(:receiver_plan_q1) do
      create(:planned_finance,
        finance_plannable: receiver,
        time_period_obj: Quarter.for_date(Date.new(2013, 1, 1)),
        primary: true
      )
    end

    let!(:giver_plan_primary) do
      create(:planned_finance,
        finance_plannable: giver,
        time_period_obj: Quarter.for_date(Date.new(2013, 4, 1)),
        primary: true
      )
    end

    let!(:giver_plan_non_primary) do
      create(:planned_finance,
        finance_plannable: giver,
        time_period_obj: Quarter.for_date(Date.new(2013, 4, 1)),
        primary: false
      )
    end

    it 'deaccumulates giver primary plan amount' do
      original_amount = giver_plan_primary.amount
      do_merge_finances!

      expect(giver_plan_primary.reload.amount).to eq(
        original_amount - receiver_plan_q1.amount
      )
    end

    it 'deaccumulates giver non primary plan amount' do
      original_amount = giver_plan_non_primary.amount
      do_merge_finances!

      expect(giver_plan_non_primary.reload.amount).to eq(
        original_amount - receiver_plan_q1.amount
      )
    end
  end

  it 'deaccumulates finances in multiple years'

  context 'when both receiver and giver have monthly spent finances within a year' do
    it 'deaccumulates receiver finance amounts that were preceded by giver finances'
    it 'does not change other receiver finance amounts'
    it 'deaccumulates giver finance amounts that were preceded by receiver finances'
    it 'does not update other giver finance amounts'
  end
end
