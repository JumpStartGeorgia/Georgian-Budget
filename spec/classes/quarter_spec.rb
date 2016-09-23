require 'rails_helper'

RSpec.describe Quarter do
  let(:date) { Date.new(2013, 1, 1) }
  let(:other_date) { Date.new(2013, 4, 1) }
  let(:quarter_for_date) { Quarter.for_date(date) }

  describe '<=>' do
    context 'when start date is before other quarter start date' do
      it 'returns -1' do
        other_date = date + 100
        expect(Quarter.for_date(date) <=> Quarter.for_date(other_date)).to eq(-1)
      end
    end

    context 'when start date is same as other quarter start date' do
      it 'returns 0' do
        other_date = date
        expect(Quarter.for_date(date) <=> Quarter.for_date(other_date)).to eq(0)
      end
    end

    context 'when start date is after other quarter start date' do
      it 'returns 1' do
        other_date = date - 100
        expect(Quarter.for_date(date) <=> Quarter.for_date(other_date)).to eq(1)
      end
    end
  end

  describe '==' do
    context 'when quarter start dates are different' do
      it 'returns false' do
        other_quarter = Quarter.for_date(quarter_for_date.start_date + 100)
        expect(quarter_for_date == other_quarter).to eq(false)
      end
    end

    context 'when quarter start dates are the same' do
      it 'returns true' do
        other_quarter = Quarter.for_date(quarter_for_date.start_date)
        expect(quarter_for_date == other_quarter).to eq(true)
      end
    end
  end

  describe '#next' do
    context 'when quarter is quarter 1' do
      it 'returns quarter 2' do
        quarter = Quarter.for_date(Date.new(2013, 1, 1))
        next_quarter = Quarter.for_date(Date.new(2013, 4, 1))

        expect(quarter.next).to eq(next_quarter)
      end
    end

    context 'when quarter is quarter 4' do
      it 'returns quarter 1 for the next year' do
        quarter = Quarter.for_date(Date.new(2013, 10, 20))
        next_quarter = Quarter.for_date(Date.new(2014, 3, 1))

        expect(quarter.next).to eq(next_quarter)
      end
    end
  end

  describe '.for_date' do
    context 'when date is in January' do
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
