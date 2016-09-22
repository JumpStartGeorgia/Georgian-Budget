FactoryGirl.define do
  factory :total do
    sequence :code do |n|
      "0#{n}"
    end
  end
end
