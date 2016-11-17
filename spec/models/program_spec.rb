require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'codeable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'nameable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_spendable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_plannable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'budget_item_duplicatable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'child_programmable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'perma_idable_spec')

RSpec.describe Program, type: :model do
  it_behaves_like 'Codeable'
  it_behaves_like 'Nameable'
  it_behaves_like 'FinanceSpendable'
  it_behaves_like 'FinancePlannable'
  it_behaves_like 'BudgetItemDuplicatable'
  it_behaves_like 'ChildProgrammable'
  it_behaves_like 'PermaIdable'

  let(:new_program) { FactoryGirl.create(:program) }
  let(:new_code_attr) { FactoryGirl.attributes_for(:code) }

  describe '#add_code' do
    context 'when code points to parent spending agency' do
      let(:agency) do
        FactoryGirl.create(:spending_agency)
      end

      before :each do
        agency.add_code(FactoryGirl.attributes_for(:code,
          number: '01 00',
          start_date: Date.new(2012, 1, 1)))

        new_code_attr[:number] = '01 01'
        new_code_attr[:start_date] = Date.new(2012, 1, 1)
      end

      context 'and it is the most recent code' do
        it 'updates program.parent to that agency' do
          new_program.add_code(new_code_attr)
          new_program.reload

          expect(new_program.parent).to eq(agency)
        end
      end

      context 'but it is not the most recent code' do
        it 'does not update program.parent attribute' do
          new_program
          .add_code(FactoryGirl.attributes_for(:code,
            number: '02 05',
            start_date: Date.new(2012, 1, 2)))
          .add_code(new_code_attr)
          new_program.reload

          expect(new_program.parent).to eq(nil)
        end
      end
    end

    context 'when code points to parent program' do
      let(:program) do
        FactoryGirl.create(:program)
      end

      before :each do
        program.add_code(FactoryGirl.attributes_for(:code,
          number: '01 01',
          start_date: Date.new(2012, 1, 1)))

        new_code_attr[:number] = '01 01 01'
        new_code_attr[:start_date] = Date.new(2012, 1, 1)
      end

      context 'and it is the most recent code' do
        it 'updates program.parent to that program' do
          new_program.add_code(new_code_attr)
          new_program.reload

          expect(new_program.parent).to eq(program)
        end
      end

      context 'and it is not the most recent code' do
        it 'does not update program.parent attribute' do
          new_program
          .add_code(FactoryGirl.attributes_for(:code,
            start_date: Date.new(2012, 1, 2)),
            number: '01 05')
          .add_code(new_code_attr)
          new_program.reload

          expect(new_program.parent).to eq(nil)
        end
      end
    end
  end

  describe '#save_perma_id' do
    it 'saves computed perma_id to perma_ids' do
      new_program.add_code(FactoryGirl.attributes_for(:code, number: '00 1'))
      new_program.add_name(FactoryGirl.attributes_for(:name, text_ka: 'a b'))

      new_program.save_perma_id

      expect(new_program.perma_id).to eq(
        Digest::SHA1.hexdigest "00_1_a_b"
      )
    end
  end
end
