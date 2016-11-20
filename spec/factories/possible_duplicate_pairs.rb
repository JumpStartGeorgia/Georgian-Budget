FactoryGirl.define do
  factory :possible_duplicate_pair do
    association :item1, factory: :program
    association :item2, factory: :program
    date_when_found Date.new(2012, 1, 1)
  end
end
