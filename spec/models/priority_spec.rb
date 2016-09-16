require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'codeable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'nameable_spec')
require Rails.root.join('spec', 'models', 'concerns', 'finance_spendable_spec')

RSpec.describe Priority, type: :model do
  it_behaves_like 'Codeable'
  it_behaves_like 'Nameable'
  it_behaves_like 'FinanceSpendable'
end
