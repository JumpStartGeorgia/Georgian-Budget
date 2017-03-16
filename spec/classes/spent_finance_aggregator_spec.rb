require 'rails_helper'

RSpec.describe SpentFinanceAggregator do
  let(:january) { Month.for_date(Date.new(2012, 1, 1)) }
  let(:february) { Month.for_date(Date.new(2012, 2, 1)) }
  let(:march) { Month.for_date(Date.new(2012, 3, 1)) }
  let(:april) { Month.for_date(Date.new(2012, 4, 1)) }

  let(:q1) { Quarter.for_date(Date.new(2012, 1, 1)) }
  let(:q2) { Quarter.for_date(Date.new(2012, 4, 1)) }

  let(:january_amount_financeable1) { 11 }
  let(:january_amount_financeable2) { 1432 }
  let(:february_amount_financeable1) { 23434 }
  let(:february_amount_financeable2) { 28994 }
  let(:march_amount) { 2000 }
  let(:april_amount) { 4 }

  describe '#create_from_monthly(Quarter)' do
    it 'saves data for priority' do
      financeable1 = FactoryGirl.create(:priority)
      financeable1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
        time_period_obj: january,
        amount: january_amount_financeable1))

      SpentFinanceAggregator.new.create_from_monthly(Quarter)

      quarterly_spent_finances = financeable1.spent_finances.quarterly

      expect(quarterly_spent_finances.length).to eq(1)
      expect(quarterly_spent_finances[0].time_period_obj).to eq(q1)
      expect(quarterly_spent_finances[0].amount).to eq(january_amount_financeable1)
      expect(quarterly_spent_finances[0].official).to eq(false)
    end

    it 'saves data for total' do
      financeable1 = FactoryGirl.create(:total)
      financeable1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
        time_period_obj: january,
        amount: january_amount_financeable1))

      SpentFinanceAggregator.new.create_from_monthly(Quarter)

      quarterly_spent_finances = financeable1.spent_finances.quarterly

      expect(quarterly_spent_finances.length).to eq(1)
      expect(quarterly_spent_finances[0].time_period_obj).to eq(q1)
      expect(quarterly_spent_finances[0].amount).to eq(january_amount_financeable1)
      expect(quarterly_spent_finances[0].official).to eq(false)
    end

    it 'saves data for spending agency' do
      financeable1 = FactoryGirl.create(:spending_agency)
      financeable1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
        time_period_obj: january,
        amount: january_amount_financeable1))

      SpentFinanceAggregator.new.create_from_monthly(Quarter)

      quarterly_spent_finances = financeable1.spent_finances.quarterly

      expect(quarterly_spent_finances.length).to eq(1)
      expect(quarterly_spent_finances[0].time_period_obj).to eq(q1)
      expect(quarterly_spent_finances[0].amount).to eq(january_amount_financeable1)
      expect(quarterly_spent_finances[0].official).to eq(false)
    end

    it 'saves data for program' do
      financeable1 = FactoryGirl.create(:program)
      financeable1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
        time_period_obj: january,
        amount: january_amount_financeable1))

      SpentFinanceAggregator.new.create_from_monthly(Quarter)

      quarterly_spent_finances = financeable1.spent_finances.quarterly

      expect(quarterly_spent_finances.length).to eq(1)
      expect(quarterly_spent_finances[0].time_period_obj).to eq(q1)
      expect(quarterly_spent_finances[0].amount).to eq(january_amount_financeable1)
      expect(quarterly_spent_finances[0].official).to eq(false)
    end

    context 'when there is a spent finance in January with nil amount' do
      it 'saves a quarter 1 spent finance with nil amount' do
        financeable1 = FactoryGirl.create(:spending_agency)
        financeable1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: january,
          amount: nil))

        SpentFinanceAggregator.new.create_from_monthly(Quarter)

        quarterly_spent_finances = financeable1.spent_finances.quarterly

        expect(quarterly_spent_finances.length).to eq(1)
        expect(quarterly_spent_finances[0].time_period_obj).to eq(q1)
        expect(quarterly_spent_finances[0].amount).to eq(nil)
        expect(quarterly_spent_finances[0].official).to eq(false)
      end
    end

    context 'when there are spent finances in Jan, Feb, and March' do
      context 'and all amounts are present' do
        it 'creates quarter 1 spent finance with sum of monthly amounts' do
          financeable1 = FactoryGirl.create(:program)
          .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: january,
            amount: january_amount_financeable1
          )).add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: february,
            amount: february_amount_financeable1
          )).add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: march,
            amount: march_amount
          ))

          SpentFinanceAggregator.new.create_from_monthly(Quarter)

          quarterly_spent_finances = financeable1.spent_finances.quarterly

          expect(quarterly_spent_finances.length).to eq(1)
          expect(quarterly_spent_finances[0].time_period_obj).to eq(q1)

          expect(quarterly_spent_finances[0].amount)
          .to eq(january_amount_financeable1 + february_amount_financeable1 + march_amount)
          expect(quarterly_spent_finances[0].official).to eq(false)
        end
      end

      context 'and March amount is nil' do
        it 'creates quarter 1 spent finance with sum of Jan and Feb amounts' do
          financeable1 = FactoryGirl.create(:spending_agency)
          .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: january,
            amount: january_amount_financeable1
          )).add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: february,
            amount: february_amount_financeable1
          )).add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: march,
            amount: nil
          ))

          SpentFinanceAggregator.new.create_from_monthly(Quarter)

          quarterly_spent_finances = financeable1.spent_finances.quarterly

          expect(quarterly_spent_finances.length).to eq(1)
          expect(quarterly_spent_finances[0].time_period_obj).to eq(q1)

          expect(quarterly_spent_finances[0].amount)
          .to eq(january_amount_financeable1 + february_amount_financeable1)

          expect(quarterly_spent_finances[0].official).to eq(false)
        end
      end

      context 'and all three amounts are nil' do
        it 'creates quarter 1 spent finance with nil amount' do
          financeable1 = FactoryGirl.create(:priority)
          .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: january,
            amount: nil
          )).add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: february,
            amount: nil
          )).add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: march,
            amount: nil
          ))

          SpentFinanceAggregator.new.create_from_monthly(Quarter)

          quarterly_spent_finances = financeable1.spent_finances.quarterly

          expect(quarterly_spent_finances.length).to eq(1)
          expect(quarterly_spent_finances[0].time_period_obj).to eq(q1)
          expect(quarterly_spent_finances[0].amount).to eq(nil)
          expect(quarterly_spent_finances[0].official).to eq(false)
        end
      end
    end

    context 'when there are monthly spent finances in January and April' do
      let(:financeable1) { FactoryGirl.create(:priority) }

      before :example do
        financeable1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: january,
          amount: january_amount_financeable1
        )).add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: april,
          amount: april_amount
        ))
      end

      it 'creates 2 quarterly spent finances' do
        SpentFinanceAggregator.new.create_from_monthly(Quarter)

        quarterly_spent_finances = financeable1.spent_finances.quarterly

        expect(quarterly_spent_finances.length).to eq(2)
      end

      it 'creates quarter 1 spent finance with January amount' do
        SpentFinanceAggregator.new.create_from_monthly(Quarter)

        quarterly_spent_finances = financeable1.spent_finances.quarterly

        expect(quarterly_spent_finances[0].time_period_obj).to eq(q1)
        expect(quarterly_spent_finances[0].amount).to eq(january_amount_financeable1)
        expect(quarterly_spent_finances[0].official).to eq(false)
      end

      it 'creates quarter 2 spent finance with April amount' do
        SpentFinanceAggregator.new.create_from_monthly(Quarter)

        quarterly_spent_finances = financeable1.spent_finances.quarterly

        expect(quarterly_spent_finances[1].time_period_obj).to eq(q2)
        expect(quarterly_spent_finances[1].amount).to eq(april_amount)
        expect(quarterly_spent_finances[1].official).to eq(false)
      end
    end

    context 'when there are two programs' do
      context 'and each have January spent finances amounts' do
        let(:financeable1) { FactoryGirl.create(:program) }
        let(:financeable2) { FactoryGirl.create(:program) }

        before :example do
          financeable1
          .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: january,
            amount: january_amount_financeable1
          )).add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: february,
            amount: february_amount_financeable1
          ))

          financeable2
          .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: january,
            amount: january_amount_financeable2
          )).add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            time_period_obj: february,
            amount: february_amount_financeable2
          ))
        end

        it 'creates a quarterly spent finance for first program' do
          SpentFinanceAggregator.new.create_from_monthly(Quarter)

          quarterly_spent_finances = financeable1.spent_finances.quarterly

          expect(quarterly_spent_finances.length).to eq(1)
          expect(quarterly_spent_finances[0].time_period_obj).to eq(q1)
          expect(quarterly_spent_finances[0].amount).to eq(
            january_amount_financeable1 + february_amount_financeable1)
          expect(quarterly_spent_finances[0].official).to eq(false)
        end

        it 'creates a quarterly spent finance for second program' do
          SpentFinanceAggregator.new.create_from_monthly(Quarter)

          quarterly_spent_finances = financeable2.spent_finances.quarterly

          expect(quarterly_spent_finances.length).to eq(1)
          expect(quarterly_spent_finances[0].time_period_obj).to eq(q1)
          expect(quarterly_spent_finances[0].amount).to eq(
            january_amount_financeable2 + february_amount_financeable2)
          expect(quarterly_spent_finances[0].official).to eq(false)
        end
      end
    end

    context 'when there are official monthly and yearly expenses' do
      let(:financeable1) { FactoryGirl.create(:program) }

      before :example do
        financeable1
        .add_spent_finance(attributes_for(:spent_finance,
          time_period_obj: Month.for_date(Date.new(2012, 1, 1)),
          official: true
        ))
        .add_spent_finance(attributes_for(:spent_finance,
          time_period_obj: Year.new(2013),
          official: true
        ))
      end

      it 'only creates quarterly finances based on monthly finance' do
        SpentFinanceAggregator.new.create_from_monthly(Quarter)

        expect(financeable1.spent_finances.quarterly.map(&:time_period_obj))
        .to contain_exactly(
          Quarter.for_date(Date.new(2012, 1, 1))
        )
      end
    end
  end

  describe '#create_from_monthly(Year)' do
    context 'when a program has 2012 and 2013 monthly finances' do
      let(:program) { FactoryGirl.create(:program) }

      before do
        program.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: january,
          amount: january_amount_financeable1))
        .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: february,
          amount: february_amount_financeable1))
        .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: Month.new(2013, 3),
          amount: march_amount))
        .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: Quarter.for_date(Date.new(2013, 1, 1))))
        .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: Month.new(2013, 3),
          official: false))

        SpentFinanceAggregator.new.create_from_monthly(Year)
      end

      it 'sums 2012 monthly finances and saves 2012 yearly finance' do
        finance = program.spent_finances.with_time_period(Year.new(2012)).first

        expect(finance).to_not eq(nil)
        expect(finance.amount).to eq(
          january_amount_financeable1 + february_amount_financeable1)
      end

      it 'sums 2013 monthly finances and saves 2013 yearly finance' do
        finance = program.spent_finances.with_time_period(Year.new(2013)).first

        expect(finance).to_not eq(nil)
        expect(finance.amount).to eq(march_amount)
      end
    end
  end
end
