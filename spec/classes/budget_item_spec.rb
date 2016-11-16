require 'rails_helper'

RSpec.describe BudgetItem do
  describe '.find_by_perma_id' do
    let(:perma_idable) { FactoryGirl.create(:program) }
    let(:perma_id_text) { 'djskflfewqfewdfdsfds' }

    context 'if the perma_id does not exist' do
      it 'returns nil' do
        expect(BudgetItem.find_by_perma_id(perma_id_text)).to eq(nil)
      end
    end

    context 'if the perma_id exists' do
      it 'returns the perma_idable' do
        perma_idable.save_perma_id(override_text: perma_id_text)

        expect(BudgetItem.find_by_perma_id(perma_id_text))
        .to eq(perma_idable)
      end
    end
  end
end
