FactoryGirl.define do
  factory :code do
    sequence :number do |n|
      "01 0#{n}"
    end

    sequence :start_date do |n|
      Date.new(2012, 1, 1) + n
    end

    association :codeable, factory: :program
  end
end
