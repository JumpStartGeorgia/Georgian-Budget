require 'rails_helper'

RSpec.shared_examples_for 'StartEndDateable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }
  let(:start_end_dateable1) { create(described_class_sym) }

  describe '#time_period_obj' do
    it 'returns time period object for start end dateable' do
      y2015_q1 = Quarter.for_date(Date.new(2015, 1, 1))
      start_end_dateable = FactoryGirl.create(
        described_class_sym,
        start_date: y2015_q1.start_date,
        end_date: y2015_q1.end_date)

      expect(start_end_dateable.time_period_obj).to eq(y2015_q1)
    end
  end

  describe '#time_period_obj=' do
    it "sets start date to time period's start date" do
      start_end_dateable1.time_period_obj = Quarter.for_date(Date.new(2011, 2, 2))

      expect(start_end_dateable1.start_date).to eq(Date.new(2011, 1, 1))
    end

    it "sets end date to time period's end date" do
      start_end_dateable1.time_period_obj = Quarter.for_date(Date.new(2011, 2, 2))

      expect(start_end_dateable1.end_date).to eq(Date.new(2011, 3, 31))
    end
  end

  describe '.with_time_period' do
    let!(:start_end_dateable_2011a) do
      create(described_class_sym, time_period_obj: Year.new(2011))
    end

    let!(:start_end_dateable_2011b) do
      create(described_class_sym, time_period_obj: Year.new(2011))
    end

    before do
      create(described_class_sym, time_period_obj: Year.new(2010))
      create(described_class_sym, time_period_obj: Year.new(2012))
    end

    it 'gets all items that match the time period obj' do
      expect(described_class.with_time_period(Year.new(2011)))
      .to contain_exactly(
        start_end_dateable_2011a, start_end_dateable_2011b
      )
    end
  end

  describe '.within_time_period' do
    let!(:start_end_dateable_2011_jan) do
      create(described_class_sym,
        time_period_obj: Month.for_date(Date.new(2011, 1, 1)))
    end

    let!(:start_end_dateable_2011_q3) do
      create(described_class_sym,
        time_period_obj: Quarter.for_date(Date.new(2011, 8, 1)))
    end

    let!(:start_end_dateable_2011) do
      create(described_class_sym, time_period_obj: Year.new(2011))
    end

    before do
      create(described_class_sym, time_period_obj: Year.new(2010))
      create(described_class_sym, time_period_obj: Year.new(2012))
    end

    it 'gets all items that have dates within the time period' do
      expect(described_class.within_time_period(Year.new(2011)))
      .to contain_exactly(
        start_end_dateable_2011_jan,
        start_end_dateable_2011_q3,
        start_end_dateable_2011
      )
    end
  end

  describe '.after' do
    let!(:start_end_dateable_2011_q3) do
      create(described_class_sym,
        time_period_obj: Quarter.for_date(Date.new(2011, 8, 1)))
    end

    let!(:start_end_dateable_2011) do
      create(described_class_sym, time_period_obj: Year.new(2011))
    end

    before do
      create(described_class_sym, time_period_obj: Year.new(2010))
    end

    it 'gets all items with start date on or after date' do
      expect(described_class.after(Date.new(2011, 1, 1)))
      .to contain_exactly(
        start_end_dateable_2011_q3,
        start_end_dateable_2011
      )
    end
  end

  describe '.before' do
    let!(:start_end_dateable_2011_q3) do
      create(described_class_sym,
        time_period_obj: Quarter.for_date(Date.new(2011, 8, 1)))
    end

    let!(:start_end_dateable_2011) do
      create(described_class_sym, time_period_obj: Year.new(2011))
    end

    before do
      create(described_class_sym, time_period_obj: Year.new(2012))
    end

    it 'gets all items with end date on or before date' do
      expect(described_class.before(Year.new(2011).end_date))
      .to contain_exactly(
        start_end_dateable_2011_q3,
        start_end_dateable_2011
      )
    end
  end
end
