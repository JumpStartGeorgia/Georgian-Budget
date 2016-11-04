require 'rails_helper'

RSpec.describe Year do
  describe '#new' do
    it 'sets start date to first day of year' do
      expect(Year.new(2015).start_date).to eq(Date.new(2015, 1, 1))
    end

    it 'sets end date to last day of year' do
      expect(Year.new(2013).end_date).to eq(Date.new(2013, 12, 31))
    end
  end

  describe '#for_date' do
    it "sets start date to first day of date's year" do
      expect(Year.for_date(Date.new(11, 6, 4)).start_date)
      .to eq(Date.new(11, 1, 1))
    end

    it "sets end date to last day of date's year" do
      expect(Year.for_date(Date.new(1341, 6, 4)).end_date)
      .to eq(Date.new(1341, 12, 31))
    end
  end

  describe '.dates_valid?' do
    it 'returns true if dates are first and last date of same year' do
      expect(Year.dates_valid?(
        Date.new(1492, 1, 1),
        Date.new(1492, 12, 31)
      )).to eq(true)
    end

    it 'returns false if first date is not first date of year' do
      expect(Year.dates_valid?(
        Date.new(1492, 1, 2),
        Date.new(1492, 12, 31)
      )).to eq(false)
    end

    it 'returns false if last date is not last date of year' do
      expect(Year.dates_valid?(
        Date.new(1492, 1, 1),
        Date.new(1492, 10, 31)
      )).to eq(false)
    end

    it 'returns false if date years are not the same' do
      expect(Year.dates_valid?(
        Date.new(1492, 1, 1),
        Date.new(1493, 12, 31)
      )).to eq(false)
    end
  end
end
