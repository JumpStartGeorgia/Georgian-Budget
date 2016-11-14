require 'rails_helper'

RSpec.describe NonCumulativeFinanceCalculator do
  let(:q4_2014) { Quarter.for_date(Date.new(2014, 10, 1)) }
  let(:q1_2015) { Quarter.for_date(Date.new(2015, 1, 1)) }
  let(:q2_2015) { Quarter.for_date(Date.new(2015, 4, 1)) }

  let(:jan_2015) { Month.for_date(Date.new(2015, 1, 1)) }

  let(:planned_f_attr_q1_2015_jan) do
    FactoryGirl.attributes_for(
      :planned_finance,
      start_date: q1_2015.start_date,
      end_date: q1_2015.end_date,
      announce_date: q1_2015.start_date
    )
  end

  let(:cumulative_amount) { 348324832 }

  describe '#calculate' do
    context 'when there are many planned finance quarters' do
      let(:planned_f_attr_q4_2014_oct) do
        FactoryGirl.attributes_for(
          :planned_finance,
          start_date: q4_2014.start_date,
          end_date: q4_2014.end_date,
          announce_date: q4_2014.start_date
        )
      end

      let(:planned_f_attr_q1_2015_jan) do
        FactoryGirl.attributes_for(
          :planned_finance,
          start_date: q1_2015.start_date,
          end_date: q1_2015.end_date,
          announce_date: q1_2015.start_date
        )
      end

      let(:planned_f_attr_q1_2015_feb) do
        FactoryGirl.attributes_for(
          :planned_finance,
          start_date: q1_2015.start_date,
          end_date: q1_2015.end_date,
          announce_date: q1_2015.start_date.next_month
        )
      end

      let(:planned_f_attr_q2_2015_april) do
        FactoryGirl.attributes_for(
          :planned_finance,
          start_date: q2_2015.start_date,
          end_date: q2_2015.end_date,
          announce_date: q2_2015.start_date
        )
      end

      it 'calculates non cumulative amount correctly' do
        financeable = FactoryGirl.create(:program)
        .add_planned_finance(planned_f_attr_q4_2014_oct)
        .add_planned_finance(planned_f_attr_q1_2015_jan)
        .add_planned_finance(planned_f_attr_q1_2015_feb)
        .add_planned_finance(planned_f_attr_q2_2015_april)

        non_cumulative_amount = NonCumulativeFinanceCalculator.new(
          finances: financeable.planned_finances,
          cumulative_amount: cumulative_amount,
          time_period: q2_2015,
          cumulative_within: Year
        ).calculate

        expect(non_cumulative_amount).to eq(
          cumulative_amount - planned_f_attr_q1_2015_feb[:amount]
        )
      end
    end

    context 'when there are different time period types' do
      let(:planned_f_attr_jan_2015) do
        FactoryGirl.attributes_for(
          :planned_finance,
          start_date: jan_2015.start_date,
          end_date: jan_2015.end_date,
          announce_date: jan_2015.start_date
        )
      end

      it 'does not include other time period types in calculations' do
        financeable = FactoryGirl.create(:spending_agency)
        .add_planned_finance(planned_f_attr_q1_2015_jan)
        .add_planned_finance(planned_f_attr_jan_2015)

        non_cumulative_amount = NonCumulativeFinanceCalculator.new(
          finances: financeable.planned_finances,
          cumulative_amount: cumulative_amount,
          time_period: q2_2015,
          cumulative_within: Year
        ).calculate

        expect(non_cumulative_amount).to eq(
          cumulative_amount - planned_f_attr_q1_2015_jan[:amount]
        )
      end
    end
  end
end
