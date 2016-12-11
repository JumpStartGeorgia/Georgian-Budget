require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'finance_spendable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_plannable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'perma_idable_spec')

RSpec.describe Total do
  it_behaves_like 'FinanceSpendable'
  it_behaves_like 'FinancePlannable'
  it_behaves_like 'PermaIdable'

  let(:total) { FactoryGirl.create(:total) }

  describe '#code' do
    it 'returns 00' do
      expect(total.code).to eq('00')
    end
  end

  describe '#name' do
    context "when I18n.locale is 'ka'" do
      it 'returns correct name' do
        I18n.locale = 'ka'
        expect(total.name).to eq('მთლიანი სახელმწიფო ბიუჯეტი')
      end
    end

    context "when I18n.locale is 'en'" do
      it 'returns correct name' do
        expect(total.name).to eq('Complete National Budget')
      end
    end
  end

  describe '#name_ka' do
    it 'returns correct name' do
      expect(total.name_ka).to eq('მთლიანი სახელმწიფო ბიუჯეტი')
    end
  end

  describe '#name_en' do
    it 'returns correct name' do
      expect(total.name_en).to eq('Complete National Budget')
    end
  end

  describe '#save_perma_id' do
    it 'saves computed perma_id to perma_ids' do
      total.save_perma_id

      expect(total.perma_id).to eq(
        Digest::SHA1.hexdigest "00_მთლიანი_სახელმწიფო_ბიუჯეტი"
      )
    end
  end

  describe '#child_programs' do
    it 'returns all top-level programs' do
      program1 = FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 01'))

      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 01 01'))

      program3 = FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '022 05'))

      expect(total.child_programs).to contain_exactly(
        program1,
        program3
      )
    end
  end

  describe '#priorities' do
    it 'returns all priorities' do
      overall_budget = FactoryGirl.create(:total)
      FactoryGirl.create_list(:priority, 4)

      expect(overall_budget.priorities.length).to eq(4)
    end
  end

  describe '#spending_agencies' do
    it 'returns all spending agencies' do
      overall_budget = FactoryGirl.create(:total)
      FactoryGirl.create_list(:spending_agency, 3)

      expect(overall_budget.spending_agencies.length).to eq(3)
    end
  end
end
