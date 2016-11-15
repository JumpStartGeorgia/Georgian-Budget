require 'rails_helper'

RSpec.describe PermaIdCreator do
  describe '.for_budget_item #compute' do
    let(:code_attr) { FactoryGirl.attributes_for(:code, number: '01 05 04') }
    let(:name_attr) { FactoryGirl.attributes_for(:name, text_ka: 'ჩემი (სახელი)') }

    context 'when name of budget item is missing' do
      it 'raises error' do
        perma_idable = FactoryGirl.create(:priority)

        expect do
          PermaIdCreator.for_budget_item(perma_idable).compute
        end.to raise_error(RuntimeError)
      end
    end

    context 'when perma_idable responds to code and name_ka' do
      context 'and both code and name_ka are present' do
        it 'returns an SHA1 hash based on the current code and cleaned name' do
          perma_idable = FactoryGirl.create(:program)
          .add_code(code_attr)
          .add_name(name_attr)

          expect(PermaIdCreator.for_budget_item(perma_idable).compute).to eq(
            Digest::SHA1.hexdigest '01_05_04_ჩემი_სახელი'
          )
        end
      end

      context 'and code is missing' do
        it 'returns nil' do
          perma_idable = FactoryGirl.create(:spending_agency)
          .add_name(name_attr)

          expect(PermaIdCreator.for_budget_item(perma_idable).compute)
          .to eq(nil)
        end
      end
    end

    context 'when perma_idable responds only to name_ka' do
      context 'and name_ka is present' do
        it 'returns an SHA1 hash based on the current name' do
          perma_idable = FactoryGirl.create(:priority)
          .add_name(name_attr)

          expect(PermaIdCreator.for_budget_item(perma_idable).compute)
          .to eq(Digest::SHA1.hexdigest 'ჩემი_სახელი')
        end
      end
    end
  end

  describe '.new #compute' do
    context 'when name and code is provided' do
      it 'returns perma_id for name and code' do
        expect(PermaIdCreator.new(
          code: '01 01 0555',
          name: 'My funky name--'
        ).compute)
        .to eq(
          Digest::SHA1.hexdigest '01_01_0555_My_funky_name'
        )
      end
    end

    context 'when only code is provided' do
      it 'raises error' do
        expect do
          PermaIdCreator.new(code: '01 01 01 01').compute
        end.to raise_error(RuntimeError)
      end
    end

    context 'when only name is provided' do
      it 'returns perma_id for name' do
        expect(PermaIdCreator.new(name: 'My funky name--').compute).to eq(
          Digest::SHA1.hexdigest 'My_funky_name'
        )
      end
    end
  end
end
