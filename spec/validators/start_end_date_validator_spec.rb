require 'rails_helper'

RSpec.shared_examples_for 'StartEndDateValidator' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }
  let(:new_spent_finance) { FactoryGirl.build(:described_class_sym) }

  describe '#start_date' do
    it 'is required' do
      new_spent_finance.start_date = nil

      expect(new_spent_finance).to have(1).error_on(:start_date)
    end
  end
  
  describe '#end_date' do
    it 'is required' do
      new_spent_finance.end_date = nil

      expect(new_spent_finance).to have(1).error_on(:end_date)
    end

    it 'throws error if before start_date' do
      new_spent_finance.end_date = new_spent_finance.start_date - 1
      new_spent_finance.valid?

      expect(new_spent_finance).to have(1).error_on(:end_date)
    end

    it 'is valid if same as start_date' do
      new_spent_finance.end_date = new_spent_finance.start_date

      expect(new_spent_finance.valid?).to eq(true)
    end

    it 'is valid if after start_date' do
      new_spent_finance.end_date = new_spent_finance.start_date + 1

      expect(new_spent_finance.valid?).to eq(true)
    end
  end
end
