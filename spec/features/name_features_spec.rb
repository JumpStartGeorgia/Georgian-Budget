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

      visit explore_path

      expect(page).to have_content(program1.name)
      expect(page).to have_content(program2.name)
      expect(page).to have_content(priority1.name)
      expect(page).to have_content(priority2.name)
    end
  end
end
