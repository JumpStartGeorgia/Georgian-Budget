require 'rails_helper'

RSpec.shared_examples_for 'WithMissingFinances' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:quarter1) { Quarter.for_date(Date.new(1990, 1, 1)) }
  let(:quarter2) { Quarter.for_date(Date.new(1990, 4, 1)) }
  let(:quarter3) { Quarter.for_date(Date.new(1990, 7, 1)) }
  let(:quarter4) { Quarter.for_date(Date.new(1990, 10, 1)) }

  let(:january) { Month.new(1991, 1) }
  let(:february) { Month.new(1991, 2) }
  let(:march) { Month.new(1991, 3) }
  let(:april) { Month.new(1991, 4) }

  let(:with_missing_financeable1) { FactoryGirl.create(described_class_sym) }

  let(:with_missing_financeable1b) do
    FactoryGirl.create(
      described_class_sym,
      parent: with_missing_financeable1.parent
    )
  end

  let(:with_missing_financeable2) { FactoryGirl.create(described_class_sym) }

  let(:finances_with_missing) do
    described_class
    .all
    .where(id: [with_missing_financeable1.id, with_missing_financeable1b.id])
    .with_missing_finances
  end

  describe '.with_missing_finances' do
    context 'when there are two monthly finances in January and April' do
      it 'adds missing finances for February and March' do
        with_missing_financeable1.update_attributes(january.to_hash)
        with_missing_financeable1b.update_attributes(april.to_hash)

        with_missing_financeable2

        expect(finances_with_missing.length).to eq(4)

        expect(finances_with_missing).to include(with_missing_financeable1)
        expect(finances_with_missing).to include(with_missing_financeable1b)

        expect(finances_with_missing).to include(
          MissingFinance.new(february.to_hash)
        )

        expect(finances_with_missing).to include(
          MissingFinance.new(march.to_hash)
        )
      end
    end

    context 'when there are finances for quarter 1 and quarter 4' do
      it 'adds missing finances for quarter 2 and 3' do
        with_missing_financeable1.update_attributes(quarter1.to_hash)
        with_missing_financeable1b.update_attributes(quarter4.to_hash)

        with_missing_financeable2

        expect(finances_with_missing.length).to eq(4)

        expect(finances_with_missing).to include(with_missing_financeable1)
        expect(finances_with_missing).to include(with_missing_financeable1b)

        expect(finances_with_missing).to include(
          MissingFinance.new(quarter2.to_hash)
        )

        expect(finances_with_missing).to include(
          MissingFinance.new(quarter3.to_hash)
        )
      end
    end
  end
end
