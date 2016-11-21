require 'rails_helper'

RSpec.describe WrongDuplicateDestroyer do
  subject(:possible_duplicate_pairs) { PossibleDuplicatePair.all }
  let(:jan_2015) { Month.new(2015, 1) }

  let!(:pair_same_codes) do
    FactoryGirl.create(:possible_duplicate_pair,
      item1: FactoryGirl.create(:program, end_date: Date.new(2012, 1, 1))
             .add_code(FactoryGirl.attributes_for(:code, number: '01 01'))
             .add_spent_finance(FactoryGirl.attributes_for(:spent_finance)),
      item2: FactoryGirl.create(:program, end_date: Date.new(2012, 1, 1))
             .add_code(FactoryGirl.attributes_for(:code, number: '01 01'))
             .add_spent_finance(FactoryGirl.attributes_for(:spent_finance))
    )
  end

  let!(:pair_different_codes) do
    FactoryGirl.create(:possible_duplicate_pair,
      item1: FactoryGirl.create(:program)
             .add_code(FactoryGirl.attributes_for(:code, number: '01 01'))
             .add_spent_finance(FactoryGirl.attributes_for(:spent_finance)),
      item2: FactoryGirl.create(:program, end_date: Date.new(2012, 1, 1))
             .add_code(FactoryGirl.attributes_for(:code, number: '01 02'))
             .add_spent_finance(FactoryGirl.attributes_for(:spent_finance))
    )
  end

  let!(:overlapping_pair_same_codes) do
    FactoryGirl.create(:possible_duplicate_pair,
      item1: FactoryGirl.create(:program)
             .add_code(FactoryGirl.attributes_for(:code, number: '01 01'))
             .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
               time_period: jan_2015)),
      item2: FactoryGirl.create(:program)
             .add_code(FactoryGirl.attributes_for(:code, number: '01 01'))
             .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
               time_period: jan_2015)),
    )
  end

  before do
    WrongDuplicateDestroyer.new.destroy_non_duplicate_pairs(possible_duplicate_pairs)
    possible_duplicate_pairs.reload
  end

  it 'removes items that are no longer possible duplicates' do
    expect(possible_duplicate_pairs).to include(pair_same_codes)
    expect(possible_duplicate_pairs).to_not include(pair_different_codes)
    expect(possible_duplicate_pairs).to_not include(overlapping_pair_same_codes)
  end
end
