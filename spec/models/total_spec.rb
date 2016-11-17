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
end
