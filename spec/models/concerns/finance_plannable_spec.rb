require 'rails_helper'

RSpec.shared_examples_for 'FinancePlannable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:q1) { Quarter.for_date(Date.new(2015, 1, 1)) }
  let(:q2) { Quarter.for_date(Date.new(2015, 4, 1)) }
  let(:q3) { Quarter.for_date(Date.new(2015, 7, 1)) }

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

  let(:planned_finance1_q1_jan) do
    planned_finance1.start_date = q1.start_date
    planned_finance1.end_date = q1.end_date
    planned_finance1.announce_date = q1.start_date

    planned_finance1
  end

  let(:planned_finance1_q1_feb) do
    planned_finance1b.start_date = q1.start_date
    planned_finance1b.end_date = q1.end_date
    planned_finance1b.announce_date = q1.start_date.next_month

    planned_finance1b
  end

  let(:planned_finance1_q2_april) do
    planned_finance1c.start_date = q2.start_date
    planned_finance1c.end_date = q2.end_date
    planned_finance1c.announce_date = q2.start_date

    planned_finance1c
  end

  let(:planned_finance1_q3_july) do
    planned_finance1d.start_date = q3.start_date
    planned_finance1d.end_date = q3.end_date
    planned_finance1d.announce_date = q3.start_date

    planned_finance1d
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
    finance_plannable1.add_planned_finance(planned_finance_attr1)
  end

  let(:added_planned_finance1b) do
    finance_plannable1.add_planned_finance(planned_finance_attr1b)
  end

  let(:added_planned_finance1c) do
    finance_plannable1.add_planned_finance(planned_finance_attr1c)
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
      planned_finance_attr1c[:start_date] = planned_finance_attr1[:start_date] + 1

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
          planned_finance_attr1b[:start_date] = planned_finance_attr1[:start_date] + 1

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
    context 'when new planned finance is unique for time period' do
      it 'sets most_recently_announced to true' do
        finance_plannable1.add_planned_finance(planned_finance_attr1)
      end
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
        let(:added_planned_finance1) do
          finance_plannable1.add_planned_finance(planned_finance_attr1)
        end

        let(:added_planned_finance1b) do
          finance_plannable1.add_planned_finance(planned_finance_attr1b)
        end

        it 'sets most_recently_announced for earlier announced planned finance to false' do
          added_planned_finance1
          added_planned_finance1b

          added_planned_finance1.reload

          expect(added_planned_finance1.most_recently_announced).to eq(false)
        end

        it 'sets most_recently_announced for new planned finance to true' do
          added_planned_finance1
          added_planned_finance1b

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
  end

  # describe '#add_planned_finance' do
  #   context 'when finance_plannable has three planned finances' do
  #     let(:planned_finance1_q1_jan) do
  #
  #     end
  #     context 'with different time periods' do
  #       it 'sets most_recently_announced to true for all three' do
  #         planned_finance1_q1_jan
  #         planned_finance1_q2_april
  #         planned_finance1_q3_july
  #
  #         expect(planned_finance1_q1_jan.reload.most_recently_announced).to eq(true)
  #         expect(planned_finance1_q2_april.most_recently_announced).to eq(true)
  #         expect(planned_finance1_q3_july.most_recently_announced).to eq(true)
  #       end
  #     end
  #
  #     context 'and two have same time periods' do
  #       it 'sets most_recently_announced to false for the older announce date'
  #     end
  #
  #     context 'and all three have same time periods' do
  #       it 'sets most_recently_announced to true only for most recent announce date' do
  #
  #       end
  #     end
  #   end
  #
  #   context 'when two finance_plannables each have a planned finance' do
  #     context 'with same time periods' do
  #       it 'sets most_recently_announced to true for both' do
  #
  #       end
  #     end
  #   end
  # end
end
