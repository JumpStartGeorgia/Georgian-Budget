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
end
