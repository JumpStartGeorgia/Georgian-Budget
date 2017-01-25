require 'rails_helper'

RSpec.shared_examples_for 'FinanceSpendable' do
  include_context 'months'
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:finance_spendable1) { FactoryGirl.create(described_class_sym) }

  let(:spent_finance_attr1a) do
    FactoryGirl.attributes_for(:spent_finance)
  end

  let(:spent_finance_attr1b) do
    FactoryGirl.attributes_for(:spent_finance)
  end

  let(:spent_finance1) do
    FactoryGirl.create(
      :spent_finance,
      finance_spendable: finance_spendable1
    )
  end

  let(:spent_finance1b) do
    FactoryGirl.create(
      :spent_finance,
      finance_spendable: finance_spendable1
    )
  end

  describe '#destroy' do
    it 'should destroy all associated spent finances' do
      create(:spent_finance,
        finance_spendable: finance_spendable1,
        primary: true)

      create(:spent_finance,
        finance_spendable: finance_spendable1,
        primary: false)

      other_finance = create(:spent_finance)

      finance_spendable1.destroy

      expect(SpentFinance.all).to contain_exactly(other_finance)
    end
  end

  describe '#spent_finances' do
    let!(:spent_feb_2015) do
      finance_spendable1.add_spent_finance(
        FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: feb_2015),
        return_finance: true)
    end

    let!(:spent_jan_2015) do
      finance_spendable1.add_spent_finance(
        FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: jan_2015,
          official: true),
        return_finance: true)
    end

    let!(:spent_jan_2015_unofficial) do
      finance_spendable1.add_spent_finance(
        FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: jan_2015,
          official: false),
        return_finance: true)
    end

    it 'gets primary spent finances ordered by start date' do
      expect(finance_spendable1.spent_finances).to match_array([
        spent_jan_2015,
        spent_feb_2015
      ])
    end
  end

  describe '#all_spent_finances' do
    let!(:spent_feb_2015) do
      finance_spendable1.add_spent_finance(
        FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: feb_2015),
        return_finance: true)
    end

    let!(:spent_jan_2015) do
      finance_spendable1.add_spent_finance(
        FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: jan_2015,
          official: true),
        return_finance: true)
    end

    let!(:spent_jan_2015_unofficial) do
      finance_spendable1.add_spent_finance(
        FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: jan_2015,
          official: false),
        return_finance: true)
    end

    it 'gets primary and non primary spent finances ordered by start date' do
      expect(finance_spendable1.all_spent_finances).to match_array([
        spent_jan_2015,
        spent_jan_2015_unofficial,
        spent_feb_2015
      ])
    end
  end

  describe '#add_spent_finance' do
    context 'when spent finance is invalid' do
      it 'throws error' do
        spent_finance_attr1a[:start_date] = nil

        expect do
          finance_spendable1.add_spent_finance(spent_finance_attr1a)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when spent finance is unofficial and alone in time period' do
      it 'marks the spent finance as primary' do
        finance = finance_spendable1.add_spent_finance(
          FactoryGirl.attributes_for(:spent_finance, official: false),
          return_finance: true)

        expect(finance.reload.primary).to eq(true)
      end
    end

    context 'when spent finance is official and alone in time period' do
      it 'marks the spent finance as primary' do
        finance = finance_spendable1.add_spent_finance(
          FactoryGirl.attributes_for(:spent_finance, official: false),
          return_finance: true)

        expect(finance.reload.primary).to eq(true)
      end
    end

    context 'when spent finance is official but has unofficial version' do
      it 'marks official as primary and unofficial as not primary' do
        unofficial_spent_attr = FactoryGirl.attributes_for(:spent_finance,
          official: false,
          time_period_obj: Year.new(2012))

        official_spent_attr = FactoryGirl.attributes_for(:spent_finance,
          official: true,
          time_period_obj: Year.new(2012))

        unofficial_spent = finance_spendable1.add_spent_finance(
          unofficial_spent_attr, return_finance: true)

        official_spent = finance_spendable1.add_spent_finance(
          official_spent_attr, return_finance: true)

        expect(official_spent.reload.primary).to eq(true)
        expect(unofficial_spent.reload.primary).to eq(false)
      end
    end

    context 'when start date is after added spent finance start date' do
      it 'updates start date to spent finance start date' do
        month = Month.for_date(Date.new(2012, 1, 1))

        finance_spendable1.start_date = month.start_date + 1
        finance_spendable1.save

        spent_finance_attr1a[:start_date] = month.start_date
        spent_finance_attr1a[:end_date] = month.end_date

        finance_spendable1.add_spent_finance(spent_finance_attr1a)

        finance_spendable1.reload
        expect(finance_spendable1.start_date).to eq(month.start_date)
      end
    end

    context 'when end date is before added spent finance end date' do
      it 'updates end date to spent finance end date' do
        month = Month.for_date(Date.new(2012, 1, 1))

        finance_spendable1.end_date = month.end_date - 1
        finance_spendable1.save

        spent_finance_attr1a[:start_date] = month.start_date
        spent_finance_attr1a[:end_date] = month.end_date

        finance_spendable1.add_spent_finance(spent_finance_attr1a)

        finance_spendable1.reload
        expect(finance_spendable1.end_date).to eq(month.end_date)
      end
    end

    context 'when spent finance is valid' do
      it 'causes finance spendable to have one spent finances' do
        finance_spendable1.add_spent_finance(spent_finance_attr1a)
        finance_spendable1.reload

        expect(finance_spendable1.spent_finances.length).to eq(1)
      end
    end

    context 'when finance spendable has earlier spent finance in same year' do
      before :example do
        jan_2012 = Month.for_date(Date.new(2012, 1, 1))
        spent_finance_attr1a[:start_date] = jan_2012.start_date
        spent_finance_attr1a[:end_date] = jan_2012.end_date
        finance_spendable1.add_spent_finance(spent_finance_attr1a)

        feb_2012 = Month.for_date(Date.new(2012, 2, 1))
        spent_finance_attr1b[:start_date] = feb_2012.start_date
        spent_finance_attr1b[:end_date] = feb_2012.end_date
      end
    end
  end

  describe '#take_spent_finance' do
    let(:spent_finance) { FactoryGirl.create(:spent_finance) }

    it 'takes spent finance away from its old finance spendable' do
      old_finance_spendable = spent_finance.finance_spendable

      finance_spendable1.take_spent_finance(spent_finance)

      expect(old_finance_spendable.spent_finances.count).to eq(0)
    end

    context 'when finance spendable has no spent finances' do
      it 'causes finance spendable to have one spent finance' do
        finance_spendable1.take_spent_finance(spent_finance)

        expect(finance_spendable1.spent_finances.count).to eq(1)
      end
    end
  end
end
