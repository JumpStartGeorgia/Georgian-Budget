require 'rails_helper'

RSpec.describe ItemFinancesMerger do
  let(:receiver) { create(:program) }
  let(:giver) { create(:program) }
  let(:do_merge_planned_finances!) do
    ItemFinancesMerger.new(receiver, giver, PlannedFinance).merge
  end

  let(:do_merge_spent_finances!) do
    ItemFinancesMerger.new(receiver, giver, SpentFinance).merge
  end

  context '' do
    before do
      create_list(:planned_finance, 2, finance_plannable: receiver)
      create_list(:planned_finance, 4, finance_plannable: giver)
    end

    it 'moves all planned finances to receiver' do
      do_merge_planned_finances!

      expect(receiver.all_planned_finances.count).to eq(6)
    end
  end

  context '' do
    before do
      create_list(:spent_finance, 2, finance_spendable: receiver)
      create_list(:spent_finance, 4, finance_spendable: giver)
    end

    it 'moves all spent finances to receiver' do
      do_merge_spent_finances!

      expect(receiver.all_spent_finances.count).to eq(6)
    end
  end

  context '' do
    let!(:receiver_plan_q1) do
      create(:planned_finance,
        finance_plannable: receiver,
        time_period_obj: Quarter.for_date(Date.new(2013, 1, 1)),
        primary: true
      )
    end

    let!(:giver_plan_q2) do
      create(:planned_finance,
        finance_plannable: giver,
        time_period_obj: Quarter.for_date(Date.new(2013, 4, 1))
      )
    end

    it 'deaccumulates quarterly planned finances' do
      original_amount = giver_plan_q2.amount
      do_merge_planned_finances!

      expect(giver_plan_q2.reload.amount).to eq(
        original_amount - receiver_plan_q1.amount
      )
    end
  end

  it 'does not deaccumulate monthly planned finances'
  it 'does not deaccumulate yearly planned finances'

  it 'deaccumulates monthly spent finances'
  it 'does not deaccumulate quarterly spent finances'
  it 'does not deaccumulate yearly spent finances'

  it 'deaccumulates receiver quarterly planned finances'
  it 'deaccumulates receiver monthly spent finances'

  context 'when giver has two plans preceded by receiver plan' do
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
      do_merge_planned_finances!

      expect(giver_plan_primary.reload.amount).to eq(
        original_amount - receiver_plan_q1.amount
      )
    end

    it 'deaccumulates giver non primary plan amount' do
      original_amount = giver_plan_non_primary.amount
      do_merge_planned_finances!

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
