require 'rails_helper'
require Rails.root.join('lib', 'budget_uploader', 'budget_files').to_s

RSpec.describe 'Deleter in Budget Uploader' do
  it 'destroys previously existing programs' do
    create_list(:priority, 2)

    BudgetFiles.new.upload

    expect(Priority.count).to eq(0)
  end
end
