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
        original_amount - receiver_plan_q1.reload.amount
      )
    end
  end

  context '' do
    let!(:receiver_plan_jan) do
      create(:planned_finance,
        finance_plannable: receiver,
        time_period_obj: Month.for_date(Date.new(2013, 1, 1)),
        primary: true
      )
    end

    let!(:giver_plan_apr) do
      create(:planned_finance,
        finance_plannable: giver,
        time_period_obj: Month.for_date(Date.new(2013, 4, 1))
      )
    end

    it 'does not deaccumulate monthly planned finances' do
      original_amount = giver_plan_apr.amount
      do_merge_planned_finances!

      expect(giver_plan_apr.reload.amount).to eq(original_amount)
    end
  end

  context '' do
    let!(:receiver_plan_2011) do
      create(:planned_finance,
        finance_plannable: receiver,
        time_period_obj: Year.new(2011),
        primary: true
      )
    end

    let!(:giver_plan_2012) do
      create(:planned_finance,
        finance_plannable: giver,
        time_period_obj: Year.new(2012)
      )
    end

    it 'does not deaccumulate yearly planned finances' do
      original_amount = giver_plan_2012.amount
      do_merge_planned_finances!

      expect(giver_plan_2012.reload.amount).to eq(original_amount)
    end
  end

  context '' do
    let!(:receiver_spent_jan) do
      create(:spent_finance,
        finance_spendable: receiver,
        time_period_obj: Month.for_date(Date.new(2012, 1, 1)),
        primary: true)
    end

    let!(:giver_spent_feb) do
      create(:spent_finance,
        finance_spendable: giver,
        time_period_obj: Month.for_date(Date.new(2012, 2, 1)))
    end

    it 'deaccumulates monthly spent finances' do
      original_amount = giver_spent_feb.amount
      do_merge_spent_finances!

      expect(giver_spent_feb.reload.amount).to eq(
        original_amount - receiver_spent_jan.reload.amount
      )
    end
  end

  context '' do
    let!(:receiver_spent_q1) do
      create(:spent_finance,
        finance_spendable: receiver,
        time_period_obj: Quarter.for_date(Date.new(2012, 1, 1)),
        primary: true)
    end

    let!(:giver_spent_q2) do
      create(:spent_finance,
        finance_spendable: giver,
        time_period_obj: Quarter.for_date(Date.new(2012, 4, 1)))
    end


    it 'does not deaccumulate quarterly spent finances' do
      original_amount = giver_spent_q2.amount
      do_merge_spent_finances!

      expect(giver_spent_q2.reload.amount).to eq(original_amount)
    end
  end

  context '' do
    let!(:receiver_spent_2011) do
      create(:spent_finance,
        finance_spendable: receiver,
        time_period_obj: Year.new(2011),
        primary: true)
    end

    let!(:giver_spent_2012) do
      create(:spent_finance,
        finance_spendable: giver,
        time_period_obj: Year.new(2012))
    end

    it 'does not deaccumulate yearly spent finances' do
      original_amount = giver_spent_2012.amount
      do_merge_spent_finances!

      expect(giver_spent_2012.reload.amount).to eq(original_amount)
    end
  end

  context '' do
    let!(:receiver_spent_jan) do
      create(:spent_finance,
        finance_spendable: receiver,
        time_period_obj: Month.for_date(Date.new(2012, 1, 1)),
        primary: false)
    end

    let!(:giver_spent_feb) do
      create(:spent_finance,
        finance_spendable: giver,
        time_period_obj: Month.for_date(Date.new(2012, 2, 1)))
    end

    it 'does not use non-primary finances to deaccumulate' do
      original_amount = giver_spent_feb.amount
      do_merge_spent_finances!

      expect(giver_spent_feb.reload.amount).to eq(original_amount)
    end
  end

  context '' do
    let!(:giver_plan_q1) do
      create(:planned_finance,
        finance_plannable: giver,
        time_period_obj: Quarter.for_date(Date.new(2013, 1, 1)),
        primary: true
      )
    end

    let!(:receiver_plan_q2) do
      create(:planned_finance,
        finance_plannable: receiver,
        time_period_obj: Quarter.for_date(Date.new(2013, 4, 1))
      )
    end

    it 'deaccumulates receiver quarterly planned finances' do
      original_amount = receiver_plan_q2.amount
      do_merge_planned_finances!

      expect(receiver_plan_q2.reload.amount).to eq(
        original_amount - giver_plan_q1.reload.amount
      )
    end
  end

  context '' do
    let!(:giver_spent_jan) do
      create(:spent_finance,
        finance_spendable: giver,
        time_period_obj: Month.for_date(Date.new(2012, 1, 1)),
        primary: true)
    end

    let!(:receiver_spent_feb) do
      create(:spent_finance,
        finance_spendable: receiver,
        time_period_obj: Month.for_date(Date.new(2012, 2, 1)))
    end

    it 'deaccumulates receiver monthly spent finances' do
      original_amount = receiver_spent_feb.amount
      do_merge_spent_finances!

      expect(receiver_spent_feb.reload.amount).to eq(
        original_amount - giver_spent_jan.reload.amount
      )
    end
  end

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
        original_amount - receiver_plan_q1.reload.amount
      )
    end

    it 'deaccumulates giver non primary plan amount' do
      original_amount = giver_plan_non_primary.amount
      do_merge_planned_finances!

      expect(giver_plan_non_primary.reload.amount).to eq(
        original_amount - receiver_plan_q1.reload.amount
      )
    end
  end

  context 'when giver and receiver have finances in two years' do
    let!(:receiver_spent_2011_jan) do
      create(:spent_finance,
        finance_spendable: receiver,
        time_period_obj: Month.for_date(Date.new(2011, 1, 1)),
        primary: true)
    end

    let!(:giver_spent_2011_feb) do
      create(:spent_finance,
        finance_spendable: giver,
        time_period_obj: Month.for_date(Date.new(2011, 2, 1)))
    end

    let!(:receiver_spent_2012_jan) do
      create(:spent_finance,
        finance_spendable: receiver,
        time_period_obj: Month.for_date(Date.new(2012, 1, 1)),
        primary: true)
    end

    let!(:giver_spent_2012_feb) do
      create(:spent_finance,
        finance_spendable: giver,
        time_period_obj: Month.for_date(Date.new(2012, 2, 1)))
    end

    it 'deaccumulates first year finances' do
      original_amount = giver_spent_2011_feb.amount
      do_merge_spent_finances!

      expect(giver_spent_2011_feb.reload.amount).to eq(
        original_amount - receiver_spent_2011_jan.reload.amount
      )
    end

    it 'deaccumulates second year finances' do
      original_amount = giver_spent_2012_feb.amount
      do_merge_spent_finances!

      expect(giver_spent_2012_feb.reload.amount).to eq(
        original_amount - receiver_spent_2012_jan.reload.amount
      )
    end
  end

  context '' do
    let!(:giver_spent_jan) do
      create(:spent_finance,
        finance_spendable: giver,
        time_period_obj: Month.for_date(Date.new(2012, 1, 1)),
        amount: nil,
        primary: true)
    end

    let!(:receiver_spent_feb) do
      create(:spent_finance,
        finance_spendable: receiver,
        time_period_obj: Month.for_date(Date.new(2012, 2, 1)))
    end

    it 'treats nil amount as 0 when removing extra accumulated amount' do
      original_amount = receiver_spent_feb.amount
      do_merge_spent_finances!

      expect(receiver_spent_feb.reload.amount).to eq(
        original_amount
      )
    end
  end

  context 'when accumulated amount is nil' do
    let!(:giver_spent_jan) do
      create(:spent_finance,
        finance_spendable: giver,
        time_period_obj: Month.for_date(Date.new(2012, 1, 1)),
        primary: true)
    end

    let!(:receiver_spent_feb) do
      create(:spent_finance,
        finance_spendable: receiver,
        amount: nil,
        time_period_obj: Month.for_date(Date.new(2012, 2, 1)))
    end

    it 'does not update it' do
      original_amount = receiver_spent_feb.amount
      do_merge_spent_finances!

      expect(receiver_spent_feb.reload.amount).to eq(
        original_amount
      )
    end
  end

  context 'when both receiver and giver have monthly spent finances within a year' do
    # putting the finances in a shared context so that it's possible to
    # collapse them (as there's so much of it)
    RSpec.shared_context 'finances' do
      let!(:receiver_spent_jan) do
        create(:spent_finance,
          finance_spendable: receiver,
          time_period_obj: Month.for_date(Date.new(2011, 1, 1)),
          primary: true)
      end

      let!(:giver_spent_feb) do
        create(:spent_finance,
          finance_spendable: giver,
          time_period_obj: Month.for_date(Date.new(2011, 2, 1)),
          primary: true)
      end

      let!(:giver_spent_march) do
        create(:spent_finance,
          finance_spendable: giver,
          time_period_obj: Month.for_date(Date.new(2011, 3, 1)),
          primary: true)
      end

      let!(:receiver_spent_april) do
        create(:spent_finance,
          finance_spendable: receiver,
          time_period_obj: Month.for_date(Date.new(2011, 4, 1)),
          primary: true)
      end

      let!(:receiver_spent_may) do
        create(:spent_finance,
          finance_spendable: receiver,
          time_period_obj: Month.for_date(Date.new(2011, 5, 1)),
          primary: true)
      end

      let!(:giver_spent_june) do
        create(:spent_finance,
          finance_spendable: giver,
          time_period_obj: Month.for_date(Date.new(2011, 6, 1)),
          primary: true)
      end

      let!(:giver_spent_july) do
        create(:spent_finance,
          finance_spendable: giver,
          time_period_obj: Month.for_date(Date.new(2011, 7, 1)),
          primary: true)
      end

      let!(:receiver_spent_aug) do
        create(:spent_finance,
          finance_spendable: receiver,
          time_period_obj: Month.for_date(Date.new(2011, 8, 1)),
          primary: true)
      end

      let!(:receiver_spent_sep) do
        create(:spent_finance,
          finance_spendable: receiver,
          time_period_obj: Month.for_date(Date.new(2011, 9, 1)),
          primary: true)
      end
    end

    include_context 'finances'

    it 'deaccumulates first giver finance preceded by receiver finances' do
      original_feb_amount = giver_spent_feb.amount

      do_merge_spent_finances!

      expect(giver_spent_feb.reload.amount).to eq(
        original_feb_amount - receiver_spent_jan.reload.amount
      )
    end

    it 'deaccumulates first receiver finance preceded by giver finances' do
      original_april_amount = receiver_spent_april.amount

      do_merge_spent_finances!

      expect(receiver_spent_april.reload.amount).to eq(
        original_april_amount - (
          giver_spent_feb.reload.amount + giver_spent_march.reload.amount
        )
      )
    end

    it 'deaccumulates second giver finance preceded by receiver finances' do
      original_june_amount = giver_spent_june.amount

      do_merge_spent_finances!

      expect(giver_spent_june.reload.amount).to eq(
        original_june_amount - (
          receiver_spent_april.reload.amount + receiver_spent_may.reload.amount
        )
      )
    end

    it 'deaccumulates second receiver finance preceded by giver finances' do
      original_aug_amount = receiver_spent_aug.amount

      do_merge_spent_finances!

      expect(receiver_spent_aug.reload.amount).to eq(
        original_aug_amount - (
          giver_spent_june.reload.amount + giver_spent_july.reload.amount
        )
      )
    end

    it "does not deaccumulate finances not preceded by other item's finances" do
      original_jan_amount = receiver_spent_jan.amount
      original_march_amount = giver_spent_march.amount
      original_may_amount = receiver_spent_may.amount
      original_july_amount = giver_spent_july.amount
      original_sep_amount = receiver_spent_sep.amount

      do_merge_spent_finances!

      expect(receiver_spent_jan.reload.amount).to eq(original_jan_amount)
      expect(giver_spent_march.reload.amount).to eq(original_march_amount)
      expect(receiver_spent_may.reload.amount).to eq(original_may_amount)
      expect(giver_spent_july.reload.amount).to eq(original_july_amount)
      expect(receiver_spent_sep.reload.amount).to eq(original_sep_amount)
    end
  end
end
