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
        if perma_idable.respond_to?(:add_code)
          perma_idable.add_code(FactoryGirl.attributes_for(:code, number: '00 1'))
        end

        if perma_idable.respond_to?(:add_name)
          perma_idable.add_name(FactoryGirl.attributes_for(:name, text: 'a b'))
        end

        perma_idable.save_perma_id

        if perma_idable.respond_to?(:add_name)
          perma_idable.add_name(FactoryGirl.attributes_for(:name, text: 'a c'))
        end

        perma_idable.save_perma_id

        expect(perma_idable.perma_id).to eq(perma_idable.perma_ids.last)
      end
    end
  end

  describe '#save_perma_id' do
    it 'saves computed perma_id to perma_ids' do
      if perma_idable.respond_to?(:add_code)
        perma_idable.add_code(FactoryGirl.attributes_for(:code, number: '00 1'))
      end

      if perma_idable.respond_to?(:add_name)
        perma_idable.add_name(FactoryGirl.attributes_for(:name, text: 'a b'))
      end

      perma_idable.save_perma_id

      expect(perma_idable.perma_id.text).to eq(
        Digest::SHA1.hexdigest "00_1_a_b"
      )
    end
  end
end
