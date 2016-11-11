require 'rails_helper'

RSpec.shared_examples_for 'FinancePlannable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:q1_2015) { Quarter.for_date(Date.new(2015, 1, 1)) }
  let(:q2_2015) { Quarter.for_date(Date.new(2015, 4, 1)) }

  let(:finance_plannable1) { FactoryGirl.create(described_class_sym) }

  let(:planned_finance1) do
    FactoryGirl.create(
      :planned_finance,
      finance_plannable: finance_plannable1
    )
  end

  let(:planned_finance1b) do
    FactoryGirl.create(
      :planned_finance,
      finance_plannable: finance_plannable1
    )
  end

  let(:planned_finance1c) do
    FactoryGirl.create(
      :planned_finance,
      finance_plannable: finance_plannable1
    )
  end

  let(:planned_finance1d) do
    FactoryGirl.create(
      :planned_finance,
      finance_plannable: finance_plannable1
    )
  end

  let(:planned_finance_attr1) do
    FactoryGirl.attributes_for(
      :planned_finance
    )
  end

  let(:planned_finance_attr1b) do
    FactoryGirl.attributes_for(
      :planned_finance
    )
  end

  let(:planned_finance_attr1c) do
    FactoryGirl.attributes_for(
      :planned_finance
    )
  end

  let(:added_planned_finance1) do
    finance_plannable1
    .add_planned_finance(planned_finance_attr1, return_finance: true)
  end

  let(:added_planned_finance1b) do
    finance_plannable1
    .add_planned_finance(planned_finance_attr1b, return_finance: true)
  end

  let(:added_planned_finance1c) do
    finance_plannable1
    .add_planned_finance(planned_finance_attr1c, return_finance: true)
  end

  describe '#destroy' do
    it 'should destroy associated planned_finances' do
      planned_finance1
      planned_finance1b

      finance_plannable1.reload
      finance_plannable1.destroy

      expect(PlannedFinance.exists?(planned_finance1.id)).to eq(false)
      expect(PlannedFinance.exists?(planned_finance1b.id)).to eq(false)
    end
  end

  describe '#planned_finances' do
    it 'gets most recently announced planned finances for the finance_plannable' do
      next_quarter = Quarter.for_date(planned_finance_attr1[:start_date]).next
      planned_finance_attr1c[:start_date] = next_quarter.start_date
      planned_finance_attr1c[:end_date] = next_quarter.end_date

      added_planned_finance1
      added_planned_finance1b
      added_planned_finance1c

      finance_plannable1.reload

      expect(finance_plannable1.planned_finances).to match_array(
        [
          added_planned_finance1b,
          added_planned_finance1c
        ]
      )
    end
  end

  describe '#all_planned_finances' do
    describe 'gets all planned finances' do
      context 'including most recent and not most recent' do
        it 'ordered by start date and then announce date' do
          ## 1b has time period after 1
          next_quarter = Quarter.for_date(planned_finance_attr1[:start_date]).next
          planned_finance_attr1b[:start_date] = next_quarter.start_date
          planned_finance_attr1b[:end_date] = next_quarter.end_date

          ## 1c was announced before 1
          planned_finance_attr1c[:announce_date] = planned_finance_attr1[:announce_date] - 1

          added_planned_finance1
          added_planned_finance1b
          added_planned_finance1c

          finance_plannable1.reload

          expect(finance_plannable1.all_planned_finances).to eq(
            [
              added_planned_finance1c,
              added_planned_finance1,
              added_planned_finance1b
            ]
          )
        end
      end
    end
  end

  describe '#add_planned_finance' do
    context 'when start date is after added spent finance start date' do
      it 'updates start date to spent finance start date' do
        month = Month.for_date(Date.new(2012, 1, 1))

        finance_plannable1.start_date = month.start_date + 1
        finance_plannable1.save

        planned_finance_attr1[:start_date] = month.start_date
        planned_finance_attr1[:end_date] = month.end_date

        finance_plannable1.add_planned_finance(planned_finance_attr1)

        finance_plannable1.reload
        expect(finance_plannable1.start_date).to eq(month.start_date)
      end
    end

    context 'when end date is before added spent finance end date' do
      it 'updates end date to spent finance end date' do
        month = Month.for_date(Date.new(2012, 1, 1))

        finance_plannable1.end_date = month.end_date - 1
        finance_plannable1.save

        planned_finance_attr1[:start_date] = month.start_date
        planned_finance_attr1[:end_date] = month.end_date

        finance_plannable1.add_planned_finance(planned_finance_attr1)

        finance_plannable1.reload
        expect(finance_plannable1.end_date).to eq(month.end_date)
      end
    end

    context 'when new planned finance is unique for time period' do
      it 'sets most_recently_announced to true'
    end

    context 'when new planned finance has earlier announced sibling for same time period' do
      before :each do
        planned_finance_attr1b[:start_date] = planned_finance_attr1[:start_date]
        planned_finance_attr1b[:end_date] = planned_finance_attr1[:end_date]
        planned_finance_attr1b[:announce_date] = planned_finance_attr1[:announce_date] + 1
      end

      context 'and sibling has same amount' do
        let(:added_planned_finance1) do
          finance_plannable1.add_planned_finance(planned_finance_attr1)
        end

        let(:added_planned_finance1b) do
          planned_finance_attr1b[:amount] = planned_finance_attr1[:amount]
          finance_plannable1.add_planned_finance(planned_finance_attr1b)
        end

        describe 'merges planned finances' do
          it 'into one record' do
            added_planned_finance1
            added_planned_finance1b
            finance_plannable1.reload

            expect(finance_plannable1.all_planned_finances.length).to eq(1)
          end

          it 'into one record with earlier announce date' do
            added_planned_finance1
            added_planned_finance1b
            finance_plannable1.reload

            expect(finance_plannable1.planned_finances[0].announce_date).to eq(
              planned_finance_attr1[:announce_date]
            )
          end
        end
      end

      context 'and sibling has different amount' do
        it 'sets most_recently_announced for earlier announced planned finance to false' do
          added_planned_finance1
          added_planned_finance1b

          added_planned_finance1.reload

          expect(added_planned_finance1.most_recently_announced).to eq(false)
        end

        it 'sets most_recently_announced for new planned finance to true' do
          added_planned_finance1
          added_planned_finance1b

          added_planned_finance1b.reload

          expect(added_planned_finance1b.most_recently_announced).to eq(true)
        end

        it 'causes #all_planned_finances to have count of 2' do
          added_planned_finance1
          added_planned_finance1b

          expect(finance_plannable1.all_planned_finances.count).to eq(2)
        end

        it 'causes #planned_finances to have count of 1' do
          added_planned_finance1
          added_planned_finance1b

          expect(finance_plannable1.planned_finances.count).to eq(1)
        end
      end
    end

    context 'when new planned finance has later announced sibling for same time period' do
      before :each do
        planned_finance_attr1b[:start_date] = planned_finance_attr1[:start_date]
        planned_finance_attr1b[:end_date] = planned_finance_attr1[:end_date]
        planned_finance_attr1b[:announce_date] = planned_finance_attr1[:announce_date] - 1
      end

      context 'and sibling has same amount' do
        let(:added_planned_finance1) do
          finance_plannable1.add_planned_finance(planned_finance_attr1)
        end

        let(:added_planned_finance1b) do
          planned_finance_attr1b[:amount] = planned_finance_attr1[:amount]
          finance_plannable1.add_planned_finance(planned_finance_attr1b)
        end

        describe 'merges planned finances' do
          it 'into one record' do
            added_planned_finance1
            added_planned_finance1b
            finance_plannable1.reload

            expect(finance_plannable1.all_planned_finances.length).to eq(1)
          end

          it 'into one record with earlier announce date' do
            added_planned_finance1
            added_planned_finance1b
            finance_plannable1.reload

            expect(finance_plannable1.planned_finances[0].announce_date).to eq(
              planned_finance_attr1b[:announce_date]
            )
          end
        end
      end
    end

    context 'when cumulative_within argument is set to Year' do
      context 'and there is an earlier planned finance in the same year' do
        before :example do
          planned_finance_attr1[:start_date] = q1_2015.start_date
          planned_finance_attr1[:end_date] = q1_2015.end_date
          planned_finance_attr1[:announce_date] = q1_2015.start_date

          finance_plannable1.add_planned_finance(planned_finance_attr1)
        end

        it 'removes that earlier amount from calculated amount' do
          planned_finance_attr1b[:start_date] = q2_2015.start_date
          planned_finance_attr1b[:end_date] = q2_2015.end_date
          planned_finance_attr1b[:announce_date] = q2_2015.start_date

          finance_plannable1.add_planned_finance(
            planned_finance_attr1b,
            cumulative_within: Year
          )

          expect(finance_plannable1.all_planned_finances[1].amount).to eq(
            planned_finance_attr1b[:amount] - planned_finance_attr1[:amount]
          )
        end
      end
    end
  end

  describe '#take_planned_finance' do
    let(:planned_finance) { FactoryGirl.create(:planned_finance) }

    it 'takes the planned finance away from its old finance plannable' do
      old_finance_plannable = planned_finance.finance_plannable

      finance_plannable1.take_planned_finance(planned_finance)

      expect(old_finance_plannable.all_planned_finances.count).to eq(0)
    end

    context 'when finance plannable has no planned finances' do
      it 'causes finance plannable to have one planned finance' do
        finance_plannable1.take_planned_finance(planned_finance)

        expect(finance_plannable1.all_planned_finances.count).to eq(1)
      end
    end
  end
end
