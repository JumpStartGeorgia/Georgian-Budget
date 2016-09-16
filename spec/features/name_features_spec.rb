require 'rails_helper'

RSpec.describe 'Name', type: :feature do
  context 'of every program and priority' do
    it 'is shown on explore page' do
      program1 = FactoryGirl.create(:program)
      FactoryGirl.create(
        :name,
        nameable: program1
      )

      program2 = FactoryGirl.create(:program)
      FactoryGirl.create(
        :name,
        nameable: program2
      )

      priority1 = FactoryGirl.create(:priority)
      FactoryGirl.create(
        :name,
        nameable: priority1
      )

      priority2 = FactoryGirl.create(:priority)
      FactoryGirl.create(
        :name,
        nameable: priority2
      )

      spending_agency1 = FactoryGirl.create(:spending_agency)
      FactoryGirl.create(
        :name,
        nameable: spending_agency1
      )

      spending_agency2 = FactoryGirl.create(:spending_agency)
      FactoryGirl.create(
        :name,
        nameable: spending_agency2
      )

      visit explore_path

      expect(page).to have_content(program1.code)
      expect(page).to have_content(program1.name)

      expect(page).to have_content(program2.code)
      expect(page).to have_content(program2.name)

      expect(page).to have_content(priority1.code)
      expect(page).to have_content(priority1.name)

      expect(page).to have_content(priority2.code)
      expect(page).to have_content(priority2.name)

      expect(page).to have_content(spending_agency1.code)
      expect(page).to have_content(spending_agency1.name)

      expect(page).to have_content(spending_agency2.code)
      expect(page).to have_content(spending_agency2.name)
    end
  end
end
