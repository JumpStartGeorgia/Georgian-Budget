require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'nameable_spec')

RSpec.describe Program, type: :model do
  it_behaves_like 'nameable'
end
