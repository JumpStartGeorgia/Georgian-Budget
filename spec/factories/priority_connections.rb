FactoryGirl.define do
  factory :priority_connection do
    sequence :start_date do |n|
      Date.new(n, 1, 1)
    end

    sequence :end_date do |n|
      Date.new(n, 12, 31)
    end

    direct false
    priority
    association :priority_connectable, factory: :spending_agency
  end
end
