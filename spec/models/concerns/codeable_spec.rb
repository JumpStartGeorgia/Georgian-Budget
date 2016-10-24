require 'rails_helper'

RSpec.shared_examples_for 'Codeable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:codeable1) { FactoryGirl.create(described_class_sym) }
  let(:codeable2) { FactoryGirl.create(described_class_sym) }

  describe '#code' do
    it 'is required' do
      codeable1.code = nil

      expect(codeable1).to have(1).errors_on(:code)
    end
  end
end
