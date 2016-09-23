FactoryGirl.define do
  factory :planned_finance do
    sequence :amount do |n|
      n * 99
    end

    start_date Date.new(2015, 1, 1)
    end_date Date.new(2015, 3, 31)
    sequence :announce_date do |n|
      Date.new(2015 + n, 1, 1)
    end

    association :finance_plannable, factory: :priority
  end
end
