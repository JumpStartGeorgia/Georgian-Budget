require 'rails_helper'

RSpec.describe TimeSeriesChart do
  let(:program) { FactoryGirl.create(:program_with_name) }

  describe '#config' do
    context 'when budget item has a name' do
      it 'includes name as top level property' do
        config = TimeSeriesChart.new(program, program.spent_finances).config

        expect(config[:name]).to eq(program.name)
      end
    end

    it 'correctly formats spent finances' do
      spent_finance1 = FactoryGirl.create(
        :spent_finance,
        start_date: Date.new(2015, 01, 01),
        end_date: Date.new(2015, 01, 31),
        finance_spendable: program
      )

      missing_finance = MissingFinance.new(
        start_date: Date.new(2015, 02, 01),
        end_date: Date.new(2015, 02, 28)
      )

      spent_finance1b = FactoryGirl.create(
        :spent_finance,
        start_date: Date.new(2015, 03, 01),
        end_date: Date.new(2015, 03, 31),
        finance_spendable: program
      )

      program.reload
      config = TimeSeriesChart.new(program, [spent_finance1, missing_finance, spent_finance1b]).config
      data = config[:data]

      expect(data[:time_periods]).to eq(['January, 2015', 'February, 2015', 'March, 2015'])
      expect(data[:amounts]).to eq([spent_finance1.amount, nil, spent_finance1b.amount])
    end
  end
end
