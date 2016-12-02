require 'rails_helper'

RSpec.shared_examples_for 'TimePeriodable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:time_periodable1) do
    FactoryGirl.build(described_class_sym)
  end

  let(:other_time_periodable) do
    FactoryGirl.build(described_class_sym)
  end

  describe '#time_period=' do
    it "sets start date to time period's start date" do
      time_periodable1.time_period_obj = Quarter.for_date(Date.new(2011, 2, 2))

      expect(time_periodable1.start_date).to eq(Date.new(2011, 1, 1))
    end

    it "sets end date to time period's end date" do
      time_periodable1.time_period_obj = Quarter.for_date(Date.new(2011, 2, 2))

      expect(time_periodable1.end_date).to eq(Date.new(2011, 3, 31))
    end
  end

  describe '#time_period_type' do
    context 'when start date and end date do not form recognizable time period' do
      it 'throws error on time period type' do
        time_period_obj = Month.for_date(Date.new(2012, 1, 1))

        time_periodable1.start_date = time_period_obj.start_date + 1
        time_periodable1.end_date = time_period_obj.end_date

        expect(time_periodable1.valid?).to eq(false)
        expect(time_periodable1).to have(1).error_on(:time_period_type)
      end
    end

    context 'when start date and end date form month' do
      it 'sets time period type to month' do
        time_periodable1.time_period_obj = Month.for_date(Date.new(2012, 1, 1))
        time_periodable1.save!

        expect(time_periodable1.time_period_type).to eq('month')
      end
    end

    context 'when start date and end date form quarter' do
      it 'sets time period type to quarter' do
        time_periodable1.time_period_obj = Quarter.for_date(Date.new(2012, 1, 1))
        time_periodable1.save!

        expect(time_periodable1.time_period_type).to eq('quarter')
      end
    end

    context 'when start date and end date form year' do
      it 'sets time period type to year' do
        time_periodable1.time_period_obj = Year.for_date(Date.new(2012, 1, 1))
        time_periodable1.save!

        expect(time_periodable1.time_period_type).to eq('year')
      end
    end
  end

  describe '' do
    before :example do
      FactoryGirl.create(
        described_class_sym,
        start_date: Date.new(2012, 1, 1),
        end_date: Date.new(2012, 1, 31))

      FactoryGirl.create(
        described_class_sym,
        start_date: Date.new(2012, 1, 1),
        end_date: Date.new(2012, 3, 31))

      FactoryGirl.create(
        described_class_sym,
        start_date: Date.new(2012, 1, 1),
        end_date: Date.new(2012, 12, 31))
    end

    describe '#monthly' do
      it 'gets only time periodables with time period type "month"' do
        monthly_time_periodables = described_class.monthly

        expect(monthly_time_periodables.length).to eq(1)
        expect(monthly_time_periodables[0].time_period_type).to eq('month')
      end
    end

    describe '#quarterly' do
      it 'gets only time periodables with time period type "quarter"' do
        quarterly_time_periodables = described_class.quarterly

        expect(quarterly_time_periodables.length).to eq(1)
        expect(quarterly_time_periodables[0].time_period_type).to eq('quarter')
      end
    end

    describe '#yearly' do
      it 'gets only time periodables with time period type "year"' do
        yearly_time_periodables = described_class.yearly

        expect(yearly_time_periodables.length).to eq(1)
        expect(yearly_time_periodables[0].time_period_type).to eq('year')
      end
    end
  end
end
