require 'rails_helper'

RSpec.describe ItemMerger do
  describe '#merge' do

    it 'destroys giver object' do
      receiver = FactoryGirl.create(:program)
      giver = FactoryGirl.create(:program)

      ItemMerger.new(receiver).merge(giver)

      expect(giver.persisted?).to eq(false)
    end

    context 'when receiver and giver do not have same class' do
      it 'throws error' do
        receiver = FactoryGirl.create(:program)
        giver = FactoryGirl.create(:spending_agency)

        expect do
          ItemMerger.new(receiver).merge(giver)
        end.to raise_error(RuntimeError)
      end
    end

    context 'when receiver object has two codes' do
      context 'and giver object has two codes, one of which can be merged' do
        it 'causes receiver object to have three codes' do
          receiver = FactoryGirl.create(:program)
          .add_code(FactoryGirl.attributes_for(
            :code,
            number: '01 01',
            start_date: Date.new(2012, 2, 1)
          )).add_code(FactoryGirl.attributes_for(
            :code,
            number: '01 02',
            start_date: Date.new(2012, 3, 1)
          ))

          giver = FactoryGirl.create(:program)
          .add_code(FactoryGirl.attributes_for(
            :code,
            number: '01 01',
            start_date: Date.new(2012, 1, 1)
          )).add_code(FactoryGirl.attributes_for(
            :code,
            number: '01 03',
            start_date: Date.new(2012, 4, 1)
          ))

          ItemMerger.new(receiver).merge(giver)

          expect(receiver.codes.count).to eq(3)
          expect(receiver.code).to eq('01 03')
        end
      end
    end
  end
end
