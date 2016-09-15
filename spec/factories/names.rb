FactoryGirl.define do
  factory :name do
    sequence :text do |n|
      "Nameable ##{n}"
    end

    start_date Date.new(2016, 1, 1)
    association :nameable, factory: :program
  end
end
