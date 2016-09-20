require 'rails_helper'

RSpec.describe MissingFinance do
  let(:start_date) { Date.new(2015, 01, 01) }
  let(:end_date) { Date.new(2015, 01, 31) }

  let(:missing_finance) do
    MissingFinance.new(start_date: start_date, end_date: end_date)
  end

  describe '.new' do
    context 'when there is no start date argument' do
      it 'throws an exception' do
        expect do
          MissingFinance.new(end_date: end_date)
        end.to raise_error(
          RuntimeError, 
          'MissingFinance must be initialized with a start date'
        )
      end
    end

    context 'when there is no end date argument' do
      it 'throws an exception' do
        expect do
          MissingFinance.new(start_date: start_date)
        end.to raise_error('MissingFinance must be initialized with an end date')
      end
    end
  end

  describe '#amount' do
    it 'returns nil' do
      expect(missing_finance.amount).to eq(nil)
    end
  end

  describe '#start_date' do
    it 'returns the start date it was initialized with' do
      expect(missing_finance.start_date).to eq(start_date)
    end
  end

  describe '#end_date' do
    it 'returns the end date it was initialized with' do
      expect(missing_finance.end_date).to eq(end_date)
    end
  end
end
