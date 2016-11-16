require 'rails_helper'

RSpec.shared_examples_for 'PermaIdable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }
  let(:perma_idable) { FactoryGirl.create(described_class_sym) }
  let(:other_perma_idable) { FactoryGirl.create(described_class_sym) }

  before :example do
    I18n.locale = 'ka'
  end

  describe '#perma_id' do
    context 'when perma_idable has no perma_ids' do
      it 'returns nil' do
        expect(perma_idable.perma_id).to eq(nil)
      end
    end

    context 'when perma_idable has multiple perma ids' do
      it 'returns last perma id' do
        perma_idable.save_perma_id(override_text: 'fdsf')
        perma_idable.save_perma_id(override_text: '28438438')

        expect(perma_idable.perma_id).to eq(perma_idable.perma_ids.last)
      end
    end
  end
end
