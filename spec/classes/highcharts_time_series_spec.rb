require 'rails_helper'

RSpec.describe HighchartsTimeSeries do
  let(:program) { FactoryGirl.create(:program_with_name) }
  
  describe '#config' do
    context 'when budget item has a name' do
      it 'includes name as top level property' do
        config = HighchartsTimeSeries.new(program, program.spent_finances).config

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

      spent_finance1b = FactoryGirl.create(
        :spent_finance,
        start_date: Date.new(2015, 02, 01),
        end_date: Date.new(2015, 02, 28),
        finance_spendable: program
      )

      program.reload
      config = HighchartsTimeSeries.new(program, program.spent_finances).config
      data = config[:data]

      expect(data[:time_periods]).to eq(['January, 2015', 'February, 2015'])
      expect(data[:amounts]).to eq([spent_finance1.amount, spent_finance1b.amount])
    end
  end
end
