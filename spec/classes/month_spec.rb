require 'rails_helper'

RSpec.describe Month do
  let(:january2015) { Month.new(2015, 1) }
  let(:february2015) { Month.new(2015, 2) }

  describe '#new' do
    it 'sets year to first argument' do
      expect(january2015.year).to eq(2015)
    end

    it 'sets month to second argument' do
      expect(february2015.month).to eq(2)
    end

    it 'sets start date to first day of month' do
      expect(january2015.start_date).to eq(Date.new(2015, 1, 1))
    end

    it 'sets end date to last day of month' do
      expect(february2015.end_date).to eq(Date.new(2015, 2, 28))
    end
  end

  describe '#between_dates' do
    context 'when start date and end date are in different months' do
      it 'raises error' do
        expect do
          Month.between_dates(Date.new(2015, 1, 1), Date.new(2015, 2, 28))
        end.to raise_error(
          RuntimeError,
          'Dates must be first and last day of same month'
        )
      end
    end

    context 'when start date is not first day of month' do
      it 'raises error' do
        expect do
          Month.between_dates(Date.new(2015, 1, 2), Date.new(2015, 1, 31))
        end.to raise_error(
          RuntimeError,
          'Dates must be first and last day of same month'
        )
      end
    end

    context 'when end date is not last day of month' do
      it 'raises error' do
        expect do
          Month.between_dates(Date.new(2015, 1, 1), Date.new(2015, 1, 30))
        end.to raise_error(
          RuntimeError,
          'Dates must be first and last day of same month'
        )
      end
    end

    context 'when dates are at beginning and end of same month' do
      it "sets year to the start date's year" do
        month = Month.between_dates(Date.new(2015, 1, 1), Date.new(2015, 1, 31))

        expect(month.year).to eq(2015)
      end

      it "sets month to the start date's month" do
        month = Month.between_dates(Date.new(2015, 1, 1), Date.new(2015, 1, 31))

        expect(month.month).to eq(1)
      end
    end
  end

  describe '#strftime' do
    it 'passes argument to start date' do
      expect(january2015.strftime('%B, %Y')).to eq('January, 2015')
    end
  end

  describe '<=>' do
    context "when start date is before second month's start date" do
      it 'returns -1' do
        expect(january2015 <=> february2015).to eq(-1)
      end
    end

    context "when start date is same as second month's start date" do
      it 'returns 0' do
        expect(january2015 <=> Month.new(2015, 1)).to eq(0)
      end
    end

    context "when start date is after second month's start date" do
      it 'returns 1' do
        expect(february2015 <=> january2015).to eq(1)
      end
    end
  end

  describe '==' do
    context "when start date is same as second month's start date" do
      it 'returns true' do
        expect(january2015 == january2015).to eq(true)
      end
    end

    context "when start date is not the same as second month's start date" do
      it 'returns false' do
        expect(january2015 == february2015).to eq(false)
      end
    end
  end
end
