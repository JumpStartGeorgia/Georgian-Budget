require 'rails_helper'

RSpec.describe Deleter do
  describe '.delete_all_budget_data' do
    it 'deletes all SpentFinance' do
      create_list(:spent_finance, 2)

      Deleter.delete_all_budget_data

      expect(SpentFinance.count).to eq(0)
    end

    it 'deletes all PlannedFinance' do
      create_list(:planned_finance, 2)

      Deleter.delete_all_budget_data

      expect(PlannedFinance.count).to eq(0)
    end

    it 'deletes programs' do
      create_list(:program, 3)

      Deleter.delete_all_budget_data

      expect(Program.count).to eq(0)
    end

    it 'deletes names' do
      create_list(:name, 2)

      Deleter.delete_all_budget_data

      expect(Name.count).to eq(0)
    end

    it 'deletes name translations' do
      create_list(:name, 2)

      Deleter.delete_all_budget_data

      # Name translations don't have their own model, so I'm not sure
      # how best to get their count. This method works.
      expect(
        Name.find_by_sql('SELECT COUNT(*) FROM name_translations')[0].count
      ).to eq(0)
    end

    it 'does not delete page contents' do
      create_list(:page_content, 3)

      Deleter.delete_all_budget_data

      expect(PageContent.count).to eq(3)
    end

    it 'does not delete roles' do
      create_list(:role, 2)

      Deleter.delete_all_budget_data

      expect(Role.count).to eq(2)
    end

    it 'does not delete users' do
      create_list(:user, 2)

      Deleter.delete_all_budget_data

      expect(User.count).to eq(2)
    end
  end
end
