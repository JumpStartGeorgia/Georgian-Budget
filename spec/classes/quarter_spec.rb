require 'rails_helper'

RSpec.describe Quarter do
  let(:quarter_for_date) { Quarter.for_date(date) }

  describe '.for_date' do
    context 'when date is in January' do
      let(:date) { Date.new(2013, 1, 1) }

      it 'sets start date to first day of January' do
        expect(quarter_for_date.start_date).to eq(
          Date.new(date.year, 1, 1)
        )
      end

      it 'sets end date to last day of March' do
        expect(quarter_for_date.end_date).to eq(
          Date.new(date.year, 3, 1).end_of_month
        )
      end
    end

    context 'when date is in May' do
      let(:date) { Date.new(2034, 5, 8) }

      it 'sets start date to first day of April' do
        expect(quarter_for_date.start_date).to eq(
          Date.new(date.year, 4, 1)
        )
      end

      it 'sets end date to last day of June' do
        expect(quarter_for_date.end_date).to eq(
          Date.new(date.year, 6, 1).end_of_month
        )
      end
    end

    context 'when date is in September' do
      let(:date) { Date.new(204, 9, 20) }

      it 'sets start date to first day of July' do
        expect(quarter_for_date.start_date).to eq(
          Date.new(date.year, 7, 1)
        )
      end

      it 'sets end date to last day of September' do
        expect(quarter_for_date.end_date).to eq(
          Date.new(date.year, 9, 1).end_of_month
        )
      end
    end

    context 'when date is in December' do
      let(:date) { Date.new(1970, 12, 31) }

      it 'sets start date to first day of October' do
        expect(quarter_for_date.start_date).to eq(
          Date.new(date.year, 10, 1)
        )
      end

      it 'sets end date to last day of December' do
        expect(quarter_for_date.end_date).to eq(
          Date.new(date.year, 12, 1).end_of_month
        )
      end
    end
  end

  describe '.new' do
    context 'when start date is not first day of quarter' do
      it 'raises error' do
        expect do
          Quarter.new(Date.new(1990, 1, 2), Date.new(1990, 3, 1).end_of_month)
        end.to raise_error(
          RuntimeError, 'Dates must be first and last day of a quarter'
        )
      end
    end

    context 'when end date is not last day of quarter' do
      it 'raises error' do
        expect do
          Quarter.new(Date.new(1990, 1, 1), Date.new(1990, 4, 1))
        end.to raise_error(
          RuntimeError, 'Dates must be first and last day of a quarter'
        )
      end
    end
  end
end
