require 'rails_helper'

RSpec.describe HighchartsTimeSeries do
  describe '#data' do
    it 'correctly formats spent finances' do
      program = FactoryGirl.create(:program)

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
      data = HighchartsTimeSeries.new(program.spent_finances).data

      expect(data[:time_periods]).to eq(['January, 2015', 'February, 2015'])
      expect(data[:amounts]).to eq([spent_finance1.amount, spent_finance1b.amount])
    end
  end
end
