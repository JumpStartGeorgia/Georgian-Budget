FactoryGirl.define do
  factory :priority do
    sequence :code do |n|
      "0#{n.to_s}"
    end
  end
end
