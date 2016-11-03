require 'rails_helper'

RSpec.shared_examples_for 'TimePeriodable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:start_date) { Date.new(2015, 01, 01) }
  let(:end_date) { Date.new(2015, 01, 31) }

  let(:time_periodable1) do
    if described_class < ApplicationRecord
      FactoryGirl.create(
        described_class_sym,
        start_date: start_date,
        end_date: end_date
      )
    else
      described_class.new(
        start_date: start_date,
        end_date: end_date
      )
    end
  end

  describe '#month' do
    it 'returns month object based on start date and end date' do
      expect(time_periodable1.month).to eq(
        Month.between_dates(start_date, end_date)
      )
    end
  end

  describe '#time_period=' do
    it "sets start date to time period's start date" do
      time_periodable1.time_period = Quarter.for_date(Date.new(2011, 2, 2))

      expect(time_periodable1.start_date).to eq(Date.new(2011, 1, 1))
    end

    it "sets end date to time period's end date" do
      time_periodable1.time_period = Quarter.for_date(Date.new(2011, 2, 2))

      expect(time_periodable1.end_date).to eq(Date.new(2011, 3, 31))
    end
  end

  describe '#time_period_type' do
    context 'when start date and end date do not form recognizable time period' do
      it 'throws error on time period type' do
        time_period = Month.for_date(Date.new(2012, 1, 1))

        time_periodable1.start_date = time_period.start_date + 1
        time_periodable1.end_date = time_period.end_date

        expect(time_periodable1.valid?).to eq(false)
        expect(time_periodable1).to have(1).error_on(:time_period_type)
      end
    end

    context 'when start date and end date form month' do
      it 'sets time period type to month' do
        time_periodable1.time_period = Month.for_date(Date.new(2012, 1, 1))
        time_periodable1.save!

        expect(time_periodable1.time_period_type).to eq('month')
      end
    end

    context 'when start date and end date form quarter' do
      it 'sets time period type to quarter' do
        time_periodable1.time_period = Quarter.for_date(Date.new(2012, 1, 1))
        time_periodable1.save!

        expect(time_periodable1.time_period_type).to eq('quarter')
      end
    end

    context 'when start date and end date form year' do
      it 'sets time period type to year' do
        time_periodable1.time_period = Year.for_date(Date.new(2012, 1, 1))
        time_periodable1.save!

        expect(time_periodable1.time_period_type).to eq('year')
      end
    end
  end
end
