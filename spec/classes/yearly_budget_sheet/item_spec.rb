require 'rails_helper'

RSpec.describe YearlyBudgetSheet::Item do
  describe '.new' do
    context 'with header_row_data' do
      it 'converts data to header_row_values' do
        require 'rubyXL'
        cell1 = instance_double(RubyXL::Cell, 'cell1')
        expect(cell1).to receive(:value).and_return(1)

        cell2 = instance_double(RubyXL::Cell, 'cell2')
        expect(cell2).to receive(:value).and_return(nil)

        cell3 = instance_double(RubyXL::Cell, 'cell3')
        expect(cell3).to receive(:value).and_return('434')

        header_row_cells = [cell1, cell2, cell3]
        header_row_data = instance_double(RubyXL::Row)
        expect(header_row_data).to receive(:cells).and_return(header_row_cells)

        item = YearlyBudgetSheet::Item.new(header_row_data: header_row_data)

        expect(item.header_row_values).to eq([1, nil, '434'])
      end
    end
  end
  describe '#two_years_earlier_spent_amount' do
    let(:item) { YearlyBudgetSheet::Item.new(header_row_values: header_row_values) }
    subject { item.two_years_earlier_spent_amount }

    context 'when fourth cell value is nil' do
      let(:header_row_values) { [double, double, double, nil] }

      it { is_expected.to eq(nil) }
    end

    context 'when fourth cell value is 1' do
      let(:header_row_values) { [double, double, double, 4] }

      it { is_expected.to eq(4000) }
    end
  end

  describe '#previous_year_plan_amount' do
    let(:item) { YearlyBudgetSheet::Item.new(header_row_values: header_row_values) }
    subject { item.previous_year_plan_amount }

    context 'when fifth cell value is nil' do
      let(:header_row_values) { [double, double, double, double, nil] }

      it { is_expected.to eq(nil) }
    end

    context 'when fifth cell value is 20' do
      let(:header_row_values) { [double, double, double, double, 20] }

      it { is_expected.to eq(20000) }
    end
  end

  describe '#current_year_plan_amount' do
    let(:item) { YearlyBudgetSheet::Item.new(header_row_values: header_row_values) }
    subject { item.current_year_plan_amount }

    context 'when sixth cell value is nil' do
      let(:header_row_values) { [double, double, double, double, double, nil] }

      it { is_expected.to eq(nil) }
    end

    context 'when sixth cell value is 4' do
      let(:header_row_values) { [double, double, double, double, double, 4] }

      it { is_expected.to eq(4000) }
    end
  end
end
