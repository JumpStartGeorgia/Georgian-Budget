require 'rails_helper'

RSpec.describe YearlyBudgetSheet::Item do
  describe '#header_row_values' do
    context 'when initialized with header_row_data' do
      let(:cell1) { instance_double(RubyXL::Cell, 'cell1') }
      let(:cell2) { instance_double(RubyXL::Cell, 'cell2') }
      let(:cell3) { instance_double(RubyXL::Cell, 'cell3') }
      let(:cell4) { nil }
      let(:header_row_cells) { [cell1, cell2, cell3, cell4] }
      let(:header_row_data) { instance_double(RubyXL::Row, 'header_row_data') }
      let(:item) { YearlyBudgetSheet::Item.new(header_row_data: header_row_data) }

      before do
        require 'rubyXL'
        expect(cell1).to receive(:value).and_return(1)
        expect(cell2).to receive(:value).and_return(nil)
        expect(cell3).to receive(:value).and_return('434')

        expect(header_row_data).to receive(:cells).and_return(header_row_cells)
      end

      it 'converts cell with number value to number in header_row_values' do
        expect(item.header_row_values[0]).to eq(1)
      end

      it 'converts cell with nil value to nil in header_row_values' do
        expect(item.header_row_values[1]).to eq(nil)
      end

      it 'converts cell with string value to string in header_row_values' do
        expect(item.header_row_values[2]).to eq('434')
      end

      it 'converts nil cell to nil in header_row_values' do
        expect(item.header_row_values[3]).to eq(nil)
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
