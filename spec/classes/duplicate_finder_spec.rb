require 'rails_helper'

RSpec.describe do DuplicateFinder
  let(:previously_saved_item) { FactoryGirl.create(:program) }
  let(:budget_item) { FactoryGirl.create(:program) }

  let(:budget_item_code_attr) do
    FactoryGirl.attributes_for(
      :code,
      number: '01 01',
      start_date: Date.new(2012, 1, 2)
    )
  end

  let(:budget_item_name_attr) do
    FactoryGirl.attributes_for(
      :name,
      text: 'My great name',
      start_date: Date.new(2012, 1, 2)
    )
  end

  describe '#find' do
    before :example do
      budget_item
      .add_code(budget_item_code_attr)
      .add_name(budget_item_name_attr)
    end

    context 'when there are no other budget items' do
      it 'returns nil as exact match' do
        duplicates = DuplicateFinder.new(budget_item).find

        expect(duplicates[:exact_match]).to eq(nil)
      end

      it 'returns empty array as possible duplicates' do
        duplicates = DuplicateFinder.new(budget_item).find

        expect(duplicates[:possible_duplicates]).to eq([])
      end
    end

    context 'when there is an item with the same code' do
      before :example do
        previously_saved_item.add_code(FactoryGirl.attributes_for(
          :code,
          number: budget_item_code_attr[:number],
          start_date: budget_item_code_attr[:start_date] - 1
        ))
      end

      context 'and the same name' do
        before :example do
          previously_saved_item.add_name(FactoryGirl.attributes_for(
            :name,
            text: budget_item_name_attr[:text],
            start_date: budget_item_name_attr[:start_date] - 1
          ))
        end

        it 'returns that item as exact match' do
          exact_match = DuplicateFinder.new(budget_item).find[:exact_match]

          expect(exact_match).to eq(previously_saved_item)
        end
      end

      context 'and a name that represents the same item' do
        before :example do
          previously_saved_item.add_name(FactoryGirl.attributes_for(
            :name,
            text: "———#{budget_item_name_attr[:text]}———",
            start_date: budget_item_name_attr[:start_date] - 1
          ))
        end

        it 'returns that item as exact match' do
          exact_match = DuplicateFinder.new(budget_item).find[:exact_match]

          expect(exact_match).to eq(previously_saved_item)
        end
      end

      context 'and a different name' do
        it 'returns that item in possible duplicates' do
          possible_duplicates = DuplicateFinder.new(budget_item).find[:possible_duplicates]

          expect(possible_duplicates).to include(previously_saved_item)
        end

        context 'and its monthly data overlaps the source item' do
          before :example do
            previously_saved_item.add_spent_finance(
              time_period: Month.for_date(Date.new(2012, 1, 1)))

            budget_item.add_spent_finance(
              time_period: Month.for_date(Date.new(2012, 1, 1)))
          end

          it 'does not return as exact match' do
            exact_match = DuplicateFinder.new(budget_item).find[:exact_match]

            expect(exact_match).to eq(nil)
          end

          it 'does not return as possible duplicate' do
            possible_duplicates = DuplicateFinder.new(budget_item).find[:possible_duplicates]

            expect(possible_duplicates).to_not include(previously_saved_item)
          end
        end
      end
    end

    context 'when there is an item with the same name' do
      before :example do
        previously_saved_item.add_name(FactoryGirl.attributes_for(
          :name,
          text: budget_item_name_attr[:text],
          start_date: budget_item_name_attr[:start_date] - 1
        ))
      end

      context 'and a different code' do
        before :example do
          previously_saved_item.add_code(FactoryGirl.attributes_for(
            :code,
            number: "#{budget_item_code_attr[:number]}1",
            start_date: budget_item_code_attr[:start_date] - 2
          ))
        end

        context 'and the items are spending agencies' do
          let(:previously_saved_item) { FactoryGirl.create(:spending_agency) }
          let(:budget_item) { FactoryGirl.create(:spending_agency) }

          it 'returns the item as an exact match' do
            exact_match = DuplicateFinder.new(budget_item).find[:exact_match]

            expect(exact_match).to eq(previously_saved_item)
          end
        end

        context 'and the items are programs' do
          context 'and they have the same number of code parts' do
            it 'returns the item as an exact match' do
              exact_match = DuplicateFinder.new(budget_item).find[:exact_match]

              expect(exact_match).to eq(previously_saved_item)
            end
          end

          context 'and they have different number of code parts' do
            before :example do
              previously_saved_item.add_code(FactoryGirl.attributes_for(
                :code,
                number: "#{budget_item_code_attr[:number]} 1",
                start_date: budget_item_code_attr[:start_date] - 1
              ))
            end

            it 'returns the item in possible duplicates' do
              possible_duplicates = DuplicateFinder.new(budget_item).find[:possible_duplicates]

              expect(possible_duplicates).to include(previously_saved_item)
            end
          end
        end
      end
    end
  end
end
