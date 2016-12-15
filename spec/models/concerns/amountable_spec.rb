require 'rails_helper'

RSpec.shared_examples_for 'Amountable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  describe '.average_amount' do
    it 'returns the mean amount of the spent finances' do
      finances = create_list(described_class_sym, 2)

      expect(described_class.average_amount).to eq(
        (finances[0].amount + finances[1].amount)/2
      )
    end
  end
end
