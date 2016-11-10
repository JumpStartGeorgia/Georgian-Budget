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

    context 'when receiver and giver have different priorities' do
      it 'throws error' do
        receiver = FactoryGirl.create(:program)
        receiver.update_attributes(priority: FactoryGirl.create(:priority))

        giver = FactoryGirl.create(:program)
        giver.update_attributes(priority: FactoryGirl.create(:priority))

        expect do
          ItemMerger.new(receiver).merge(giver)
        end.to raise_error(RuntimeError)
      end
    end

    context 'when receiver priority is nil and giver has priority' do
      it "updates receiver priority to giver's priority" do
        receiver = FactoryGirl.create(:program)

        giver = FactoryGirl.create(:program)
        priority = FactoryGirl.create(:priority)
        giver.update_attributes(priority: priority)

        ItemMerger.new(receiver).merge(giver)

        expect(receiver.priority).to eq(priority)
      end
    end

    context 'when receiver object has two codes' do
      context 'and giver object has two codes, one of which can be merged' do
        it 'merges giver codes into receiver' do
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

    context 'when name object has two codes' do
      context 'and giver object has two names, one of which can be merged' do
        it 'merges giver names into receiver' do
          receiver = FactoryGirl.create(:spending_agency)
          .add_name(FactoryGirl.attributes_for(
            :name,
            text: 'Name 1',
            start_date: Date.new(2012, 2, 1)
          )).add_name(FactoryGirl.attributes_for(
            :name,
            text: 'Name 2',
            start_date: Date.new(2012, 3, 1)
          ))

          giver = FactoryGirl.create(:spending_agency)
          .add_name(FactoryGirl.attributes_for(
            :name,
            text: 'Name 1',
            start_date: Date.new(2012, 1, 1)
          )).add_name(FactoryGirl.attributes_for(
            :name,
            text: 'Name 3',
            start_date: Date.new(2012, 4, 1)
          ))

          ItemMerger.new(receiver).merge(giver)

          expect(receiver.names.count).to eq(3)
          expect(receiver.name).to eq('Name 3')
        end
      end
    end
  end
end
