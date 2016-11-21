require 'rails_helper'

RSpec.describe do DuplicateFinder
  let(:previously_saved_item) { FactoryGirl.create(:program) }
  let(:previously_saved_item2) { FactoryGirl.create(:program) }
  let(:source_item) { FactoryGirl.create(:program) }

  let(:source_item_code_attr) do
    FactoryGirl.attributes_for(
      :code,
      number: '01 01',
      start_date: Date.new(2012, 2, 1)
    )
  end

  let(:source_item_name_attr) do
    FactoryGirl.attributes_for(
      :name,
      text: 'My great name',
      start_date: Date.new(2012, 2, 1)
    )
  end

  before :example do
    source_item
    .add_code(source_item_code_attr)
    .add_name(source_item_name_attr)
    .update_attribute(:end_date, source_item_code_attr[:start_date].end_of_month)
  end

  describe '#find_exact_match' do
    context 'when there are no other budget items' do
      it 'returns nil as exact match' do
        exact_match = DuplicateFinder.new(source_item).find_exact_match

        expect(exact_match).to eq(nil)
      end
    end

    context 'when there is an item with the same code' do
      before :example do
        previously_saved_item.add_code(FactoryGirl.attributes_for(
          :code,
          number: source_item_code_attr[:number],
          start_date: source_item_code_attr[:start_date] - 1
        ))
      end

      context 'and the same name' do
        before :example do
          previously_saved_item.add_name(FactoryGirl.attributes_for(
            :name,
            text: source_item_name_attr[:text],
            start_date: source_item_name_attr[:start_date] - 1
          ))
        end

        it 'returns that item as exact match' do
          exact_match = DuplicateFinder.new(source_item).find_exact_match

          expect(exact_match).to eq(previously_saved_item)
        end
      end

      context 'and a name that represents the same item' do
        before :example do
          previously_saved_item.add_name(FactoryGirl.attributes_for(
            :name,
            text: "———#{source_item_name_attr[:text]}———",
            start_date: source_item_name_attr[:start_date] - 1
          ))
        end

        it 'returns that item as exact match' do
          exact_match = DuplicateFinder.new(source_item).find_exact_match

          expect(exact_match).to eq(previously_saved_item)
        end
      end

      context 'and a different name' do
        context 'and its monthly data overlaps the source item' do
          before :example do
            previously_saved_item.add_spent_finance(
              time_period: Month.for_date(Date.new(2012, 1, 1)))

            source_item.add_spent_finance(
              time_period: Month.for_date(Date.new(2012, 1, 1)))
          end

          it 'does not return as exact match' do
            exact_match = DuplicateFinder.new(source_item).find_exact_match

            expect(exact_match).to eq(nil)
          end
        end
      end
    end

    context 'when there is an item with the same name' do
      before :example do
        previously_saved_item.add_name(FactoryGirl.attributes_for(
          :name,
          text: source_item_name_attr[:text],
          start_date: source_item_name_attr[:start_date] - 1
        ))
      end

      context 'and a different code' do
        before :example do
          previously_saved_item.add_code(FactoryGirl.attributes_for(
            :code,
            number: "#{source_item_code_attr[:number]}1",
            start_date: source_item_code_attr[:start_date] - 2
          ))
        end

        context 'and the items are spending agencies' do
          let(:previously_saved_item) { FactoryGirl.create(:spending_agency) }
          let(:source_item) { FactoryGirl.create(:spending_agency) }

          it 'returns the item as an exact match' do
            exact_match = DuplicateFinder.new(source_item).find_exact_match

            expect(exact_match).to eq(previously_saved_item)
          end
        end

        context 'and the items are programs' do
          context 'and they have the same number of code parts' do
            it 'returns the item as an exact match' do
              exact_match = DuplicateFinder.new(source_item).find_exact_match

              expect(exact_match).to eq(previously_saved_item)
            end
          end

          context 'and they have different number of code parts' do
            before :example do
              previously_saved_item.add_code(FactoryGirl.attributes_for(
                :code,
                number: "#{source_item_code_attr[:number]} 1",
                start_date: source_item_code_attr[:start_date] - 1
              ))
            end
          end
        end
      end
    end
  end

  describe '#find_possible_duplicates' do
    context 'when there are no other budget items' do
      it 'returns empty array as possible duplicates' do
        possible_duplicates = DuplicateFinder.new(source_item).find_possible_duplicates

        expect(possible_duplicates).to eq([])
      end
    end

    context 'when there are multiple items with same code' do
      it 'returns only the most recent in possible duplicates' do
        previously_saved_item.add_code(FactoryGirl.attributes_for(:code,
          number: source_item_code_attr[:number]))
        previously_saved_item
        .update_attribute(:start_date, Date.new(2011, 1, 1))

        previously_saved_item2.add_code(FactoryGirl.attributes_for(:code,
          number: source_item_code_attr[:number]))
        previously_saved_item2
        .update_attribute(:start_date, Date.new(2010, 1, 1))

        possible_duplicates = DuplicateFinder.new(source_item).find_possible_duplicates

        expect(possible_duplicates).to eq([previously_saved_item])
      end
    end

    context 'when previous item had same code earlier but diff code now' do
      it 'returns the item in possible duplicates' do
        previously_saved_item
        .add_code(FactoryGirl.attributes_for(:code,
          number: source_item_code_attr[:number],
          start_date: source_item_code_attr[:start_date] - 2))
        .add_code(FactoryGirl.attributes_for(:code,
          start_date: source_item_code_attr[:start_date] + 4))

        possible_duplicates = DuplicateFinder.new(source_item).find_possible_duplicates

        expect(possible_duplicates).to eq([previously_saved_item])
      end
    end

    context 'when there is an item with the same code' do
      before :example do
        previously_saved_item.add_code(FactoryGirl.attributes_for(
          :code,
          number: source_item_code_attr[:number],
          start_date: source_item_code_attr[:start_date] - 1
        ))
      end

      context 'and a different name' do
        context 'and the item starts after source item ends' do
          it 'does not return that item in possible duplicates' do
            source_item.update_attribute(:end_date, Date.new(2012, 4, 1))
            previously_saved_item.update_attribute(:start_date, source_item.end_date + 1)

            possible_duplicates = DuplicateFinder.new(source_item).find_possible_duplicates

            expect(possible_duplicates).to_not include(previously_saved_item)
          end
        end

        context 'and the item starts the same day source item ends' do
          it 'returns that item in possible duplicates' do
            source_item.update_attribute(:end_date, Date.new(2012, 4, 1))
            previously_saved_item.update_attribute(:start_date, source_item.end_date)

            possible_duplicates = DuplicateFinder.new(source_item).find_possible_duplicates

            expect(possible_duplicates).to include(previously_saved_item)
          end
        end

        context 'and the item starts before the source item ends' do
          it 'returns that item in possible duplicates' do
            source_item.update_attribute(:end_date, Date.new(2012, 4, 1))
            previously_saved_item.update_attribute(:start_date, source_item.end_date - 1)

            possible_duplicates = DuplicateFinder.new(source_item).find_possible_duplicates

            expect(possible_duplicates).to include(previously_saved_item)
          end
        end

        context 'and its monthly data overlaps the source item' do
          before :example do
            previously_saved_item.add_spent_finance(
              time_period: Month.for_date(Date.new(2012, 1, 1)))

            source_item.add_spent_finance(
              time_period: Month.for_date(Date.new(2012, 1, 1)))
          end

          it 'does not return as possible duplicate' do
            possible_duplicates = DuplicateFinder.new(source_item).find_possible_duplicates

            expect(possible_duplicates).to_not include(previously_saved_item)
          end
        end
      end
    end

    context 'when there is an item with the same name' do
      before :example do
        previously_saved_item.add_name(FactoryGirl.attributes_for(
          :name,
          text: source_item_name_attr[:text],
          start_date: source_item_name_attr[:start_date] - 1
        ))
      end

      context 'and a different code' do
        before :example do
          previously_saved_item.add_code(FactoryGirl.attributes_for(
            :code,
            number: "#{source_item_code_attr[:number]}1",
            start_date: source_item_code_attr[:start_date] - 2
          ))
        end

        context 'and the items are programs' do
          context 'and they have different number of code parts' do
            before :example do
              previously_saved_item.add_code(FactoryGirl.attributes_for(
                :code,
                number: "#{source_item_code_attr[:number]} 1",
                start_date: source_item_code_attr[:start_date] - 1
              ))
            end

            it 'returns the item in possible duplicates' do
              possible_duplicates = DuplicateFinder.new(source_item).find_possible_duplicates

              expect(possible_duplicates).to include(previously_saved_item)
            end
          end
        end
      end
    end
  end
end
