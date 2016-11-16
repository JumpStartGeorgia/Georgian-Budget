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

  describe '.find' do
    context 'when name and code arguments are provided' do
      context 'and matching perma id exists' do
        it "returns that perma_id's perma_idable" do
          perma_idable = FactoryGirl.create(:program)
          .add_name(FactoryGirl.attributes_for(:name, text_ka: 'ჩემი სახელი'))
          .add_code(FactoryGirl.attributes_for(:code, number: '12 34 56'))
          .save_perma_id

          expect(BudgetItem.find(name: 'ჩემი სახელი', code: '12 34 56'))
          .to eq(perma_idable)
        end
      end

      context 'and no matching perma id exists' do
        it "returns nil" do
          perma_idable = FactoryGirl.create(:program)
          .add_name(FactoryGirl.attributes_for(:name, text_ka: 'ჩემი სახელი'))
          .save_perma_id

          expect(BudgetItem.find(name: 'ჩემი სახელი', code: '12 34 56'))
          .to eq(nil)
        end
      end
    end

    context 'when only name is provided' do
      context 'and perma_idable exists with just name' do
        it 'returns that perma_idable' do
          perma_idable = FactoryGirl.create(:priority)
          .add_name(FactoryGirl.attributes_for(:name, text_ka: 'ჩემი სახელი'))
          .save_perma_id

          expect(BudgetItem.find(name: 'ჩემი სახელი')).to eq(perma_idable)
        end
      end

      context 'and perma_idable exists with same name but also code' do
        it 'does not return perma_idable' do
          perma_idable = FactoryGirl.create(:program)
          .add_name(FactoryGirl.attributes_for(:name, text_ka: 'ჩემი სახელი'))
          .add_code(FactoryGirl.attributes_for(:code, number: '12 34 56'))
          .save_perma_id

          expect(BudgetItem.find(name: 'ჩემი სახელი')).to eq(nil)
        end
      end
    end

    context 'when name is not provided' do
      it 'returns nil' do
        perma_idable = FactoryGirl.create(:program)
        .add_name(FactoryGirl.attributes_for(:name, text_ka: 'ჩემი სახელი'))
        .add_code(FactoryGirl.attributes_for(:code, number: '12 34 56'))
        .save_perma_id

        expect(BudgetItem.find(code: '12 34 56')).to eq(nil)
      end
    end

    it 'uses aggressively cleaned version of name' do
      perma_idable = FactoryGirl.create(:program)
      .add_name(FactoryGirl.attributes_for(:name, text_ka: 'ჩემი სახელი'))
      .add_code(FactoryGirl.attributes_for(:code, number: '12 34 56'))
      .save_perma_id

      expect(BudgetItem.find(name: '--ჩემი— —სახელი--', code: '12 34 56'))
      .to eq(perma_idable)
    end
  end
end
