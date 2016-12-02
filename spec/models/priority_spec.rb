require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'nameable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_spendable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_plannable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'perma_idable_spec')

RSpec.describe Priority, type: :model do
  it_behaves_like 'Nameable'
  it_behaves_like 'FinanceSpendable'
  it_behaves_like 'FinancePlannable'
  it_behaves_like 'PermaIdable'

  let(:priority) { FactoryGirl.create(:priority) }

  describe '#update_finances' do
    context 'when priority has no programs' do
      it 'adds no spent finances to priority' do
        priority.update_finances

        expect(priority.spent_finances.length).to eq(0)
      end

      it 'adds no planned finances to priority' do
        priority.update_finances

        expect(priority.planned_finances.length).to eq(0)
      end
    end

    context 'when priority has two programs' do
      let(:program1) do
        FactoryGirl.create(
          :program,
          code: '01 01',
          priority: priority)
      end

      let(:program2) do
        FactoryGirl.create(
          :program,
          code: '01 02',
          priority: priority)
      end

      context 'with spent finances' do
        let(:program1_spent_finance1_amount) { 241 }
        let(:program2_spent_finance1_amount) { 2414 }

        let(:program1_spent_finance2_amount) { 343 }
        let(:program2_spent_finance2_amount) { nil }

        let(:program1_spent_finance3_amount) { nil }

        let(:spent_finance_time_period1) { Month.for_date(Date.new(2012, 1, 1)) }
        let(:spent_finance_time_period2) { Month.for_date(Date.new(2012, 7, 1)) }
        let(:spent_finance_time_period3) { Month.for_date(Date.new(2013, 1, 1)) }

        before :example do
          program1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            amount: program1_spent_finance1_amount,
            time_period_obj: spent_finance_time_period1))

          program2.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            amount: program2_spent_finance1_amount,
            time_period_obj: spent_finance_time_period1))

          program1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            amount: program1_spent_finance2_amount,
            time_period_obj: spent_finance_time_period2))

          program2.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            amount: program2_spent_finance2_amount,
            time_period_obj: spent_finance_time_period2))

          program1.add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
            amount: program1_spent_finance3_amount,
            time_period_obj: spent_finance_time_period3))
        end

        it "sets priority's spent finances to program spent finance sums" do
          priority.update_finances

          expect(priority.spent_finances[0].time_period_obj).to eq(
            spent_finance_time_period1)

          expect(priority.spent_finances[0].amount).to eq(
            program1_spent_finance1_amount + program2_spent_finance1_amount)

          expect(priority.spent_finances[0].official).to eq(false)

          expect(priority.spent_finances[1].time_period_obj).to eq(
            spent_finance_time_period2)

          expect(priority.spent_finances[1].amount).to eq(
            program1_spent_finance2_amount)

          expect(priority.spent_finances[1].official).to eq(false)

          expect(priority.spent_finances[2].time_period_obj).to eq(
            spent_finance_time_period3)

          expect(priority.spent_finances[2].amount).to eq(
            program1_spent_finance3_amount)

          expect(priority.spent_finances[2].official).to eq(false)
        end
      end

      context 'with planned finances' do
        context 'and four planned finances are in same quarter' do
          let(:planned_finance_time_period1) { Quarter.for_date(Date.new(2012, 1, 1)) }

          let(:planned_finance_q1_jan) { priority.all_planned_finances[0] }
          let(:planned_finance_announce_date1a) { Date.new(2012, 1, 1) }
          let(:program1_planned_finance1a_amount) { 434559 }

          let(:planned_finance_q1_feb) { priority.all_planned_finances[1] }
          let(:planned_finance_announce_date1b) { Date.new(2012, 2, 1) }
          let(:program1_planned_finance1b_amount) { 343 }
          let(:program2_planned_finance1b_amount) { 2414 }

          let(:planned_finance_q1_march) { priority.all_planned_finances[2] }
          let(:planned_finance_announce_date1c) { Date.new(2012, 3, 1) }
          let(:program2_planned_finance1c_amount) { 23111 }

          before :example do
            program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
              time_period_obj: planned_finance_time_period1,
              announce_date: planned_finance_announce_date1a,
              amount: program1_planned_finance1a_amount))

            program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
              time_period_obj: planned_finance_time_period1,
              announce_date: planned_finance_announce_date1b,
              amount: program1_planned_finance1b_amount))

            program2.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
              time_period_obj: planned_finance_time_period1,
              announce_date: planned_finance_announce_date1b,
              amount: program2_planned_finance1b_amount))

            program2.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
              time_period_obj: planned_finance_time_period1,
              announce_date: planned_finance_announce_date1c,
              amount: program2_planned_finance1c_amount))
          end

          it 'creates planned finance without at the time unannounced program plans' do
            priority.update_finances

            expect(planned_finance_q1_jan.amount).to eq(
              program1_planned_finance1a_amount)

            expect(planned_finance_q1_jan.official).to eq(false)
          end

          it 'creates planned finance with program plans announced on same date when available' do
            priority.update_finances

            expect(planned_finance_q1_feb.amount).to eq(
              program1_planned_finance1b_amount +
              program2_planned_finance1b_amount)

            expect(planned_finance_q1_feb.official).to eq(false)
          end

          it 'creates planned finance with most recent program plans for time period' do
            priority.update_finances

            expect(planned_finance_q1_march.amount).to eq(
              program1_planned_finance1b_amount +
              program2_planned_finance1c_amount)

            expect(planned_finance_q1_march.official).to eq(false)
          end
        end

        context 'when two programs have planned finances for quarter but one has nil amount' do
          let(:planned_finance_time_period2) { Quarter.for_date(Date.new(2012, 10, 1)) }

          let(:planned_finance_announce_date2) { Date.new(2012, 10, 1) }
          let(:program1_planned_finance2_amount) { 2222 }
          let(:program2_planned_finance2_amount) { nil }

          before :each do
            program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
              time_period_obj: planned_finance_time_period2,
              announce_date: planned_finance_announce_date2,
              amount: program1_planned_finance2_amount))

            program2.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
              time_period_obj: planned_finance_time_period2,
              announce_date: planned_finance_announce_date2,
              amount: program2_planned_finance2_amount))
          end

          it 'creates planned finance for quarter from non-nil finance' do
            priority.update_finances

            expect(priority.all_planned_finances[0].amount).to eq(
              program1_planned_finance2_amount)

            expect(priority.all_planned_finances[0].official).to eq(false)
          end
        end

        context 'when only one program has planned finance for quarter and amount is nil' do
          let(:q3) { Quarter.for_date(q3_august_announce_date) }

          let(:q3_august_announce_date) { Date.new(2012, 8, 1) }
          let(:program1_planned_finance_q3_august_amount) { nil }

          before :example do
            program1.add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
              time_period_obj: q3,
              announce_date: q3_august_announce_date,
              amount: program1_planned_finance_q3_august_amount))
          end

          it 'creates planned finance with nil amount' do
            priority.update_finances

            expect(priority.all_planned_finances[0].amount).to eq(
              program1_planned_finance_q3_august_amount)

            expect(priority.all_planned_finances[0].official).to eq(false)
          end
        end
      end
    end
  end

  describe '#save_perma_id' do
    it 'saves computed perma_id to perma_ids' do
      priority.add_name(FactoryGirl.attributes_for(:name, text_ka: 'a b'))
      priority.save_perma_id

      expect(priority.perma_id).to eq(
        Digest::SHA1.hexdigest "a_b"
      )
    end
  end

  describe '#spending_agencies' do
    context "when priority's programs belong to two agencies" do
      let!(:agency1) { FactoryGirl.create(:spending_agency) }
      let!(:agency2) { FactoryGirl.create(:spending_agency) }

      before do
        FactoryGirl.create(:program, parent: agency1, priority: priority)
        FactoryGirl.create(:program, parent: agency1, priority: priority)
        program = FactoryGirl.create(:program, parent: agency2, priority: priority)
        FactoryGirl.create(:program, parent: program, priority: priority)
      end

      it 'returns those two agencies' do
        expect(priority.spending_agencies).to contain_exactly(agency1, agency2)
      end
    end
  end
end
