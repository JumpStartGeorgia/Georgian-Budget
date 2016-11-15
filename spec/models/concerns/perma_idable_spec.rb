require 'rails_helper'

RSpec.shared_examples_for 'PermaIdable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }
  let(:perma_idable) { FactoryGirl.create(described_class_sym) }
  let(:other_perma_idable) { FactoryGirl.create(described_class_sym) }

  describe '#save_perma_id' do
    context 'when perma_id argument exists in perma_ids table' do
      it 'does not save perma_id to perma_ids' do
        perma_id = 'fdsafjkd;jfj'
        other_perma_idable.save_perma_id(perma_id)

        perma_idable.save_perma_id(perma_id)

        expect(perma_idable.perma_ids).to eq([])
      end
    end

    context 'and perma_id argument does not exist in perma_ids table' do
      it 'saves perma_id to perma_ids' do
        perma_id = 'fdsafjkd;jfj'
        perma_idable.save_perma_id(perma_id)

        expect(perma_idable.perma_ids[0].text).to eq(perma_id)
      end
    end
  end
end
