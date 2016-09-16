FactoryGirl.define do
  factory :spending_agency do
    sequence :code do |n|
      "0#{n.to_s} 00"
    end
  end
end
