require 'rails_helper'

RSpec.describe TimePeriod do
  let(:january1) { Date.new(2015, 1, 1) }
  let(:january2) { Date.new(2015, 1, 2) }
  let(:january30) { Date.new(2015, 1, 30) }
  let(:january31) { Date.new(2015, 1, 31) }
  let(:february1) { Date.new(2015, 2, 1) }
  let(:february28) { Date.new(2015, 2, 28) }

  describe '#month' do
    context 'when start_date is not first day of a month' do
      it 'returns nil' do
        tp = TimePeriod.new(january2, january31)

        expect(tp.month).to eq(nil)
      end
    end

    context 'when end_date is not last day of month' do
      it 'returns nil' do
        tp = TimePeriod.new(january1, january30)

        expect(tp.month).to eq(nil)
      end
    end

    context 'when start_date and end_date are not in the same month' do
      it 'returns nil' do
        tp = TimePeriod.new(january1, february28)

        expect(tp.month).to eq(nil)
      end
    end

    context 'when dates are beginning and end of month' do
      context 'in January 2015' do
        it 'returns nicely formatted string of that month and year' do
          tp = TimePeriod.new(january1, january31)

          expect(tp.month).to eq('January, 2015')
        end
      end

      context 'in February 2015' do
        it 'returns nicely formatted string of that month and year' do
          tp = TimePeriod.new(february1, february28)

          expect(tp.month).to eq('February, 2015')
        end
      end
    end
  end
end
