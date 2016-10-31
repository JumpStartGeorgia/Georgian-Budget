FactoryGirl.define do
  factory :possible_duplicate_pair do
    association :item1, factory: :program
    association :item2, factory: :program
  end
end
