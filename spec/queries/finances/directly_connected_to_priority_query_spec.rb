require 'rails_helper'

RSpec.describe Finances::DirectlyConnectedToPriorityQuery do
  let(:priority) { create(:priority) }

  describe '#call' do
    let(:directly_connected_spent_finances!) do
      Finances::DirectlyConnectedToPriorityQuery
      .new(priority, SpentFinance)
      .call
    end

    let(:directly_connected_planned_finances!) do
      Finances::DirectlyConnectedToPriorityQuery
      .new(priority, PlannedFinance)
      .call
    end

    it 'returns finances belonging to directly connected items in connected period' do
      finance1 = create(:spent_finance, time_period_obj: Year.new(2012))
      finance2 = create(:spent_finance,
        time_period_obj: Quarter.for_date(Date.new(2013, 1, 1)),
        finance_spendable: finance1.finance_spendable)

      finance3 = create(:spent_finance,
        time_period_obj: Month.for_date(Date.new(2014, 1, 1)))

      create(:priority_connection,
        start_date: Date.new(2012, 1, 1),
        end_date: Date.new(2013, 12, 1),
        priority_connectable: finance1.finance_spendable,
        priority: priority,
        direct: true)

      create(:priority_connection,
        time_period_obj: Year.new(2014),
        priority_connectable: finance3.finance_spendable,
        priority: priority,
        direct: true)

      expect(directly_connected_spent_finances!)
      .to contain_exactly(finance1, finance2, finance3)
    end

    it 'does not return finance belonging to directly connected item but in different period' do
      finance = create(:spent_finance, time_period_obj: Year.new(2014))

      create(:priority_connection,
        time_period_obj: Year.new(2013),
        priority_connectable: finance.finance_spendable,
        priority: priority,
        direct: true)

      expect(directly_connected_spent_finances!)
      .to be_empty
    end

    it 'does not return unconnected finance' do
      create(:spent_finance)

      expect(directly_connected_spent_finances!)
      .to be_empty
    end

    it 'does not return indirectly connected finance' do
      finance = create(:spent_finance, time_period_obj: Year.new(2013))

      create(:priority_connection,
        time_period_obj: Year.new(2013),
        priority_connectable: finance.finance_spendable,
        priority: priority,
        direct: false)

      expect(directly_connected_spent_finances!)
      .to be_empty
    end

    it 'returns only official finance even if there is directly connected unofficial version' do
      year_2013 = Year.new(2013)
      official_plan = create(:planned_finance,
        time_period_obj: year_2013,
        announce_date: year_2013.start_date,
        official: true)

      create(:planned_finance,
        time_period_obj: year_2013,
        announce_date: year_2013.start_date,
        official: false)

      create(:priority_connection,
        time_period_obj: year_2013,
        priority_connectable: official_plan.finance_plannable,
        priority: priority,
        direct: true)


      expect(directly_connected_planned_finances!)
      .to contain_exactly(official_plan)
    end
  end
end
