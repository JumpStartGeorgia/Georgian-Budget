require 'rails_helper'

RSpec.describe TimePeriods::SpreadsheetsContainingItem do
  describe '.call' do
    let(:program) { create(:program) }

    context 'when item has official monthly expenses' do
      before do
        create(:spent_finance,
          budget_item: program,
          official: true,
          time_period_obj: Month.for_date(Date.new(2012, 1, 1)))
      end

      it 'outputs array of those monthly expenses' do
        expect(TimePeriods::SpreadsheetsContainingItem.call(program)).to eq(
          [
            Month.for_date(Date.new(2012, 1, 1)),
          ]
        )
      end
    end

    context 'when item has official quarterly plans' do
      before do
        create(:planned_finance,
          budget_item: program,
          official: true,
          announce_date: Date.new(2013, 2, 1),
          time_period_obj: Quarter.for_date(Date.new(2013, 2, 1)))
      end

      it 'outputs array of the months those plans were announced' do
        expect(TimePeriods::SpreadsheetsContainingItem.call(program)).to eq(
          [
            Month.for_date(Date.new(2013, 2, 1))
          ]
        )
      end
    end

    context 'when item has official yearly plans' do
      before do
        create(:planned_finance,
          budget_item: program,
          official: true,
          announce_date: Date.new(2011, 1, 1),
          time_period_obj: Year.new(2012))
      end

      it 'outputs array of the years in which those plans were announced' do
        expect(TimePeriods::SpreadsheetsContainingItem.call(program)).to eq(
          [
            Year.new(2011)
          ]
        )
      end
    end

    context 'when item has official yearly expenses' do
      before do
        create(:spent_finance,
          budget_item: program,
          official: true,
          time_period_obj: Year.new(2016))
      end

      it 'outputs time periods two years ahead of these expenses' do
        expect(TimePeriods::SpreadsheetsContainingItem.call(program)).to eq(
          [
            Year.new(2018)
          ]
        )
      end
    end

    context 'when item has finances from same time period' do
      before do
        create(:planned_finance,
          budget_item: program,
          official: true,
          announce_date: Date.new(2016, 1, 1),
          time_period_obj: Year.new(2015))

        create(:spent_finance,
          budget_item: program,
          official: true,
          time_period_obj: Year.new(2014))
      end

      it 'only outputs that time period once' do
        expect(TimePeriods::SpreadsheetsContainingItem.call(program)).to eq(
          [
            Year.new(2016)
          ]
        )
      end
    end

    context 'when item has unofficial items' do
      before do
        create(:planned_finance,
          budget_item: program,
          official: false,
          announce_date: Date.new(2016, 1, 1),
          time_period_obj: Year.new(2015))
      end

      it 'does not include them in outputted array' do
        expect(TimePeriods::SpreadsheetsContainingItem.call(program)).to eq([])
      end
    end

    it 'sorts items by start date' do
      create(:planned_finance,
        budget_item: program,
        official: true,
        announce_date: Date.new(2016, 1, 1),
        time_period_obj: Year.new(2015))

      create(:planned_finance,
        budget_item: program,
        official: true,
        announce_date: Date.new(2013, 2, 1),
        time_period_obj: Quarter.for_date(Date.new(2013, 2, 1)))

      create(:spent_finance,
        budget_item: program,
        official: true,
        time_period_obj: Month.for_date(Date.new(2012, 1, 1)))

      expect(TimePeriods::SpreadsheetsContainingItem.call(program)).to eq(
        [
          Month.for_date(Date.new(2012, 1, 1)),
          Month.for_date(Date.new(2013, 2, 1)),
          Year.new(2016)
        ]
      )
    end
  end
end
