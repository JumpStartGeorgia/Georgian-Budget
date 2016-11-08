require 'rails_helper'

RSpec.describe BudgetItemFetcher do
  let(:fetcher_code_number_program) { '01 01' }
  let(:fetcher_code_number_agency) { '01 00' }

  let(:fetcher_name_text) { 'My, fun-name!' }
  describe '#fetch' do
    context 'when matching budget item cannot be found' do
      context 'and create_if_nil argument is true' do
        it 'creates and returns new budget item' do
          fetched_item = BudgetItemFetcher.new.fetch({
            code_number: fetcher_code_number_program,
            name_text: fetcher_name_text,
            create_if_nil: true
          })

          expect(fetched_item.class).to eq(Program)
          expect(fetched_item.persisted?).to eq(true)
        end

        it 'makes #created_new_item return true' do
          fetcher = BudgetItemFetcher.new

          fetcher.fetch({
            code_number: fetcher_code_number_program,
            name_text: fetcher_name_text,
            create_if_nil: true
          })

          expect(fetcher.created_new_item).to eq(true)
        end
      end

      context 'and create_if_nil argument is not provided' do
        it 'returns nil' do
          fetched_item = BudgetItemFetcher.new.fetch({
            code_number: fetcher_code_number_program,
            name_text: fetcher_name_text,
            create_if_nil: false
          })

          expect(fetched_item).to eq(nil)
        end

        it 'makes #created_new_item return false' do
          fetcher = BudgetItemFetcher.new

          fetcher.fetch({
            code_number: fetcher_code_number_program,
            name_text: fetcher_name_text,
            create_if_nil: false
          })

          expect(fetcher.created_new_item).to eq(false)
        end
      end
    end

    context 'when previously saved item is Program' do
      let(:previously_saved_item) { FactoryGirl.create(:program) }

      context 'and name is the same' do
        before :example do
          previously_saved_item.add_name(
            FactoryGirl.attributes_for(:name, text: fetcher_name_text))
        end

        context 'but code is different' do
          before :example do
            previously_saved_item.add_code(
              FactoryGirl.attributes_for(:code, number: '01 02'))
          end

          it 'returns nil' do
            fetcher = BudgetItemFetcher.new

            expect(fetcher.fetch({
              code_number: fetcher_code_number_program,
              name_text: fetcher_name_text,
              create_if_nil: false
            })).to eq(nil)
          end
        end

        context 'and code is the same' do
          before :example do
            previously_saved_item.add_code(
              FactoryGirl.attributes_for(:code, number: fetcher_code_number_program))
          end

          it 'returns that item' do
            fetcher = BudgetItemFetcher.new

            expect(fetcher.fetch({
              code_number: fetcher_code_number_program,
              name_text: fetcher_name_text,
              create_if_nil: false
            })).to eq(previously_saved_item)
          end
        end
      end
      context 'and name is functionally the same' do
        before :example do
          previously_saved_item.add_name(
            FactoryGirl.attributes_for(:name, text: 'My fun—name!'))
        end

        context 'and code is the same' do
          before :example do
            previously_saved_item.add_code(
              FactoryGirl.attributes_for(:code, number: fetcher_code_number_program))
          end

          it 'returns the previously saved item' do
            fetcher = BudgetItemFetcher.new

            expect(fetcher.fetch({
              code_number: fetcher_code_number_program,
              name_text: fetcher_name_text,
              create_if_nil: false
            })).to eq(previously_saved_item)
          end
        end
      end
    end

    context 'when previously saved item is Spending Agency' do
      let(:previously_saved_item) do
        FactoryGirl.create(:spending_agency)
      end

      context 'and name is the same' do
        before :example do
          previously_saved_item.add_name(
            FactoryGirl.attributes_for(:name, text: fetcher_name_text)
          )
        end

        context 'but code is different' do
          before :example do
            previously_saved_item.add_code(
              FactoryGirl.attributes_for(:code, number: '02 00'))
          end

          it 'returns that item' do
            fetcher = BudgetItemFetcher.new

            expect(fetcher.fetch({
              code_number: fetcher_code_number_agency,
              name_text: fetcher_name_text,
              create_if_nil: false
            })).to eq(previously_saved_item)
          end
        end

        context 'and code is the same' do
          before :example do
            previously_saved_item.add_code(
              FactoryGirl.attributes_for(:code, number: fetcher_code_number_agency))
          end

          it 'returns that item' do
            fetcher = BudgetItemFetcher.new

            expect(fetcher.fetch({
              code_number: fetcher_code_number_agency,
              name_text: fetcher_name_text,
              create_if_nil: false
            })).to eq(previously_saved_item)
          end
        end
      end
      context 'and name is functionally the same' do
        before :example do
          previously_saved_item.add_name(
            FactoryGirl.attributes_for(:name, text: 'My fun—name!'))
        end

        context 'and code is the same' do
          before :example do
            previously_saved_item.add_code(
              FactoryGirl.attributes_for(:code, number: fetcher_code_number_agency))
          end

          it 'returns the previously saved item' do
            fetcher = BudgetItemFetcher.new

            expect(fetcher.fetch({
              code_number: fetcher_code_number_agency,
              name_text: fetcher_name_text,
              create_if_nil: false
            })).to eq(previously_saved_item)
          end
        end
      end
    end
  end
end
