require 'rails_helper'

RSpec.shared_examples_for 'FinanceSpendable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:finance_spendable1) { FactoryGirl.create(described_class_sym) }

  let(:spent_finance_attr1a) { FactoryGirl.attributes_for(:spent_finance) }
  let(:spent_finance_attr1b) { FactoryGirl.attributes_for(:spent_finance) }

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
    it 'should destroy associated spent_finances' do
      spent_finance1
      spent_finance1b

      finance_spendable1.destroy

      expect(SpentFinance.exists?(spent_finance1.id)).to eq(false)
      expect(SpentFinance.exists?(spent_finance1b.id)).to eq(false)
    end
  end

  describe '#spent_finances' do
    it 'gets all spent finances for the finance_spendable' do
      expect(finance_spendable1.spent_finances).to match_array([spent_finance1, spent_finance1b])
    end

    it 'are ordered by start date' do
      spent_finance1
      spent_finance1b.time_period = spent_finance1.time_period.next
      spent_finance1b.save!

      expect(finance_spendable1.spent_finances).to eq(
        [spent_finance1, spent_finance1b]
      )
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
  end
end
