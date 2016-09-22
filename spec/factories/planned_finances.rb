FactoryGirl.define do
  factory :planned_finance do
    sequence :amount do |n|
      n * 99
    end

    start_date Date.new(2015, 1, 1)

    sequence :end_date do |n|
      Date.new(2015 + n, 3, 1).end_of_month
    end

    association :finance_plannable, factory: :priority
  end
end
