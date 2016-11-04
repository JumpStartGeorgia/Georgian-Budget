require 'rails_helper'

RSpec.describe Quarter do
  let(:date) { Date.new(2013, 1, 1) }
  let(:other_date) { Date.new(2013, 4, 1) }
  let(:quarter_for_date) { Quarter.for_date(date) }

  let(:q1) { Quarter.for_date(Date.new(2015, 1, 1)) }
  let(:q2) { Quarter.for_date(Date.new(2015, 4, 1)) }
  let(:q3) { Quarter.for_date(Date.new(2015, 7, 1)) }
  let(:q4) { Quarter.for_date(Date.new(2015, 10, 1)) }

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

  describe '#to_s' do
    context 'when quarter is first quarter of 2015' do
      it 'returns "Quarter #1, 2015"' do
        quarter = Quarter.for_date(Date.new(2015, 2, 4))
        expect(quarter.to_s).to eq('Quarter #1, 2015')
      end
    end

    context 'when quarter is fourth of 1234' do
      it 'returns "Quarter #4, 1234"' do
        quarter = Quarter.for_date(Date.new(1234, 10, 4))
        expect(quarter.to_s).to eq('Quarter #4, 1234')
      end
    end
  end

  describe '#to_i' do
    context 'when quarter is first' do
      it 'return 1' do
        expect(q1.to_i).to eq(1)
      end
    end

    context 'when quarter is second' do
      it 'return 2' do
        expect(q2.to_i).to eq(2)
      end
    end

    context 'when quarter is third' do
      it 'return 3' do
        expect(q3.to_i).to eq(3)
      end
    end

    context 'when quarter is fourth' do
      it 'return 4' do
        expect(q4.to_i).to eq(4)
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

  describe '.valid_dates?' do
    it 'returns false for year dates' do
      expect(Quarter.dates_valid?(
        Date.new(2012, 1, 1),
        Date.new(2012, 12, 31)
      )).to eq(false)
    end
  end

  describe '.for_dates' do
    context 'when argument is empty array' do
      it 'returns empty array' do
        expect(Quarter.for_dates([])).to eq([])
      end
    end

    context 'when argument is array of one date' do
      it 'returns array of quarter for that date' do
        expect(Quarter.for_dates([
          Date.new(2012, 12, 1)
        ])).to eq([
          Quarter.for_date(Date.new(2012, 10, 1)),
        ])
      end
    end

    context 'when argument is array of two dates in different quarters' do
      it 'returns array of quarters for both of those dates' do
        expect(Quarter.for_dates([
          Date.new(2012, 12, 1),
          Date.new(2013, 5, 1)
        ])).to eq([
          Quarter.for_date(Date.new(2012, 10, 1)),
          Quarter.for_date(Date.new(2013, 4, 1))
        ])
      end
    end

    context 'when argument is array of two dates in same quarter' do
      it 'returns an array containing the quarter for those dates' do
        expect(Quarter.for_dates([
          Date.new(2012, 12, 1),
          Date.new(2012, 12, 1)
        ])).to eq([
          Quarter.for_date(Date.new(2012, 10, 1))
        ])
      end
    end
  end
end
