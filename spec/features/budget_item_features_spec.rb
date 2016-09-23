require 'rails_helper'

RSpec.describe 'BudgetItem' do
  let(:q1) { Quarter.for_date(Date.new(2014, 1, 1)) }
  let(:q2) { Quarter.for_date(Date.new(2014, 4, 1)) }
  let(:q3) { Quarter.for_date(Date.new(2014, 7, 1)) }
  let(:q4) { Quarter.for_date(Date.new(2014, 10, 1)) }

  describe 'finances' do
    it 'are displayed on the show page of a program' do
      program1 = FactoryGirl.create(:program_with_name)

      spent_finance1 = FactoryGirl.create(
        :spent_finance,
        finance_spendable: program1
      )

      spent_finance2 = FactoryGirl.create(
        :spent_finance,
        start_date: spent_finance1.start_date,
        end_date: spent_finance1.start_date + 1,
        finance_spendable: program1
      )

      program1_q1_planned1 = program1.add_planned_finance({
        amount: 500,
        time_period: q1,
        announce_date: q1.start_date
      })

      program1.add_planned_finance({
        amount: 500,
        time_period: q1,
        announce_date: q1.start_date.next_month
      })

      program1_q1_planned1b = program1.add_planned_finance({
        amount: 1000,
        time_period: q1,
        announce_date: q1.start_date.next_month.next_month
      })

      program1_q2_planned1 = program1.add_planned_finance({
        amount: 99999,
        time_period: q2,
        announce_date: q2.start_date
      })

      visit nameable_path(program1.class.to_s.underscore, program1.id)

      expect(page).to have_content("#{spent_finance1.start_date} - #{spent_finance1.end_date}: #{spent_finance1.amount_pretty}")
      expect(page).to have_content("#{spent_finance2.start_date} - #{spent_finance2.end_date}: #{spent_finance2.amount_pretty}")

      expect(page).to have_content("#{q1.to_s}: #{program1_q1_planned1.amount}")
      expect(page).to have_content("#{q1.to_s}: #{program1_q1_planned1b.amount} (most recently announced)")
      expect(page).to have_content("#{q2.to_s}: #{program1_q2_planned1.amount}")
    end
  end
end
