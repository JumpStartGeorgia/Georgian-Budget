require 'rails_helper'

RSpec.describe 'Name', type: :feature do
  context 'of every program' do
    it 'is shown on explore page' do
      program1 = FactoryGirl.create(:program)
      FactoryGirl.create(
        :name,
        text: 'Program #1',
        start_date: Date.yesterday,
        end_date: Date.today,
        nameable: program1
      )

      program2 = FactoryGirl.create(:program)
      FactoryGirl.create(
        :name,
        text: 'Program #2',
        start_date: Date.yesterday,
        end_date: Date.today,
        nameable: program2
      )

      visit explore_path

      expect(page).to have_content(program1.name)
      expect(page).to have_content(program2.name)
    end
  end
end
