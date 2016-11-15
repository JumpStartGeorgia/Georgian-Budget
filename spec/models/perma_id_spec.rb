require 'rails_helper'

RSpec.describe PermaId, type: :model do
  let(:new_perma_id) { FactoryGirl.build(:perma_id) }

  context 'with required attributes' do
    it 'is valid' do
      expect(new_perma_id.valid?).to eq(true)
    end
  end

  describe '#text' do
    it 'cannot be nil' do
      new_perma_id.text = nil

      expect(new_perma_id.valid?).to eq(false)
      expect(new_perma_id).to have(1).errors_on(:text)
    end

    it 'cannot be empty string' do
      new_perma_id.text = ''

      expect(new_perma_id.valid?).to eq(false)
      expect(new_perma_id).to have(1).errors_on(:text)
    end

    it 'is unique' do
      FactoryGirl.create(:perma_id, text: new_perma_id.text)

      expect(new_perma_id.valid?).to eq(false)
      expect(new_perma_id).to have(1).errors_on(:text)
    end
  end

  describe '#perma_idable' do
    it 'is required' do
      new_perma_id.perma_idable = nil

      expect(new_perma_id.valid?).to eq(false)
      expect(new_perma_id).to have(1).errors_on(:perma_idable)
    end
  end
end
