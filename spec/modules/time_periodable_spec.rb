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
end