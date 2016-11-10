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

    context 'when receiver object has two names' do
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

    context 'when receiver object has april 2012 and april 2013 spent finances' do
      let(:receiver) { FactoryGirl.create(:spending_agency) }
      let(:giver) { FactoryGirl.create(:spending_agency) }

      let(:receiver_spent_f_april_2012) do
        time_period = Month.for_date(Date.new(2012, 4, 1))

        FactoryGirl.attributes_for(
          :spent_finance,
          start_date: time_period.start_date,
          end_date: time_period.end_date
        )
      end

      let(:receiver_spent_f_april_2013) do
        time_period = Month.for_date(Date.new(2013, 4, 1))

        FactoryGirl.attributes_for(
          :spent_finance,
          start_date: time_period.start_date,
          end_date: time_period.end_date
        )
      end

      before :each do
        receiver
        .add_spent_finance(receiver_spent_f_april_2012)
        .add_spent_finance(receiver_spent_f_april_2013)
      end

      context 'and giver object has may 2013 and june 2013 spent finances' do
        let(:giver_spent_f_may_2013) do
          time_period = Month.for_date(Date.new(2013, 5, 1))

          FactoryGirl.attributes_for(
            :spent_finance,
            start_date: time_period.start_date,
            end_date: time_period.end_date
          )
        end

        let(:giver_spent_f_june_2013) do
          time_period = Month.for_date(Date.new(2013, 6, 1))

          FactoryGirl.attributes_for(
            :spent_finance,
            start_date: time_period.start_date,
            end_date: time_period.end_date
          )
        end

        before :each do
          giver
          .add_spent_finance(giver_spent_f_may_2013)
          .add_spent_finance(giver_spent_f_june_2013)
        end

        it 'causes receiver object to have four monthly spent finances' do
          ItemMerger.new(receiver).merge(giver)

          expect(receiver.spent_finances.monthly.count).to eq(4)
        end

        it 'saves may 2013 finance amount by calculating non cumulative amount' do
          ItemMerger.new(receiver).merge(giver)

          expect(receiver.spent_finances.monthly[2].amount).to eq(
            giver_spent_f_may_2013[:amount] - receiver_spent_f_april_2013[:amount]
          )
        end

        it 'saves june 2013 finance amount directly from giver' do
          ItemMerger.new(receiver).merge(giver)

          expect(receiver.spent_finances.monthly[3].amount).to eq(
            giver_spent_f_june_2013[:amount]
          )
        end
      end
    end

    context 'when receiver object has 2012 spent finance' do
      let(:receiver) { FactoryGirl.create(:spending_agency) }
      let(:giver) { FactoryGirl.create(:spending_agency) }

      let(:receiver_spent_f_2012) do
        time_period = Year.for_date(Date.new(2012, 1, 1))

        FactoryGirl.attributes_for(
          :spent_finance,
          start_date: time_period.start_date,
          end_date: time_period.end_date
        )
      end

      before :each do
        receiver.add_spent_finance(receiver_spent_f_2012)
      end

      context 'and giver object has 2013 spent finance' do
        let(:giver_spent_f_2013) do
          time_period = Year.for_date(Date.new(2013, 1, 1))

          FactoryGirl.attributes_for(
            :spent_finance,
            start_date: time_period.start_date,
            end_date: time_period.end_date
          )
        end

        before :each do
          giver.add_spent_finance(giver_spent_f_2013)
        end

        it 'causes receiver to have two yearly spent finances' do
          ItemMerger.new(receiver).merge(giver)

          expect(receiver.spent_finances.yearly.count).to eq(2)
        end

        it "takes giver's 2013 finance amount directly" do
          ItemMerger.new(receiver).merge(giver)

          expect(receiver.spent_finances.yearly.last.amount).to eq(
            giver_spent_f_2013[:amount]
          )
        end
      end
    end
  end
end
