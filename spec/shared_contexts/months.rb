require 'rails_helper'

RSpec.shared_context 'months' do
  let(:jan_2015) { Month.new(2015, 1) }
  let(:feb_2015) { Month.new(2015, 2) }
end
