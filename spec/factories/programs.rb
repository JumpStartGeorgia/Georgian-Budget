FactoryGirl.define do
  factory :program do
    sequence :code do |n|
      "01 #{n.to_s}"
    end
  end
end
