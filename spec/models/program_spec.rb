require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'codeable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'nameable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_spendable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_plannable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'budget_item_duplicatable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'perma_idable_spec')

RSpec.describe Program, type: :model do
  it_behaves_like 'Codeable'
  it_behaves_like 'Nameable'
  it_behaves_like 'FinanceSpendable'
  it_behaves_like 'FinancePlannable'
  it_behaves_like 'BudgetItemDuplicatable'
  it_behaves_like 'PermaIdable'
  it_behaves_like 'PriorityConnectable'

  let(:new_program) { FactoryGirl.create(:program) }
  let(:new_code_attr) { FactoryGirl.attributes_for(:code) }

  describe '#add_code' do
    let!(:agency0200) do
      FactoryGirl.create(:spending_agency)
      .add_code(FactoryGirl.attributes_for(:code,
        number: '02 00',
        start_date: Date.new(2012, 1, 1)))
    end

    let!(:agency0100) do
      FactoryGirl.create(:spending_agency)
      .add_code(FactoryGirl.attributes_for(:code,
        number: '01 00',
        start_date: Date.new(2012, 1, 1)))
    end

    let!(:program0101) do
      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code,
        number: '01 01',
        start_date: Date.new(2012, 1, 1)))
    end

    context 'when code is the most recent' do
      it 'updates parent program and spending agency' do
        new_program
        .add_code(FactoryGirl.attributes_for(:code,
          number: '01 01 01',
          start_date: Date.new(2012, 1, 1)))

        new_program.reload

        expect(new_program.spending_agency).to eq(agency0100)
        expect(new_program.parent_program).to eq(program0101)
      end
    end

    context 'when code is not the most recent' do
      it 'does not update parent program and spending agency' do
        new_program
        .add_code(FactoryGirl.attributes_for(:code,
          number: '02 05',
          start_date: Date.new(2012, 1, 2)))
        .add_code(FactoryGirl.attributes_for(:code,
          number: '01 01 01',
          start_date: Date.new(2012, 1, 1)))

        new_program.reload

        expect(new_program.spending_agency).to eq(agency0200)
        expect(new_program.parent_program).to eq(nil)
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

  describe '#child_programs' do
    it 'returns programs that point to the new program' do
      children = FactoryGirl.create_list(:program, 2, parent_program: new_program)

      FactoryGirl.create(:program)

      new_program.reload
      expect(new_program.child_programs).to contain_exactly(children[0], children[1])
    end
  end
end
