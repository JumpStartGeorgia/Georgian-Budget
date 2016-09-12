require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'nameable_spec')

RSpec.describe Priority, type: :model do
  it_behaves_like 'nameable'
end
