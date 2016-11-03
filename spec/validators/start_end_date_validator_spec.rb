require 'rails_helper'

RSpec.shared_examples_for 'StartEndDateValidator' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }
  let(:new_subject) { FactoryGirl.build(described_class_sym) }

  describe '#start_date' do
    it 'is required' do
      new_subject.start_date = nil

      expect(new_subject).to have(1).error_on(:start_date)
    end
  end

  describe '#end_date' do
    it 'is required' do
      new_subject.end_date = nil

      expect(new_subject).to have(1).error_on(:end_date)
    end

    it 'throws error if before start_date' do
      new_subject.end_date = new_subject.start_date - 1
      new_subject.valid?

      expect(new_subject).to have(1).error_on(:end_date)
    end

    it 'if same as start_date has zero errors on end_date' do
      new_subject.end_date = new_subject.start_date

      expect(new_subject).to have(0).error_on(:end_date)
    end

    it 'if after start_date has zero errors on end_date' do
      new_subject.end_date = new_subject.start_date + 1

      expect(new_subject).to have(0).error_on(:end_date)
    end
  end
end
