require 'rails_helper'

RSpec.describe 'BudgetCodeMapper' do
  describe '#class_for_code' do
    it 'returns Total for "00"' do
      expect(BudgetCodeMapper.class_for_code('00')).to eq(Total)
    end

    it 'returns Priority for "01"' do
      expect(BudgetCodeMapper.class_for_code('01')).to eq(Priority)

    end

    it 'returns Priority for "02"' do
      expect(BudgetCodeMapper.class_for_code('02')).to eq(Priority)
    end

    it 'returns SpendingAgency for "01 00"' do
      expect(BudgetCodeMapper.class_for_code('01 00')).to eq(SpendingAgency)
    end

    it 'returns Program for "01 01"' do
      expect(BudgetCodeMapper.class_for_code('01 01')).to eq(Program)
    end

    it 'returns Program for "01 01 01"' do
      expect(BudgetCodeMapper.class_for_code('01 01 01')).to eq(Program)
    end
  end
end
