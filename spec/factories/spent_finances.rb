FactoryGirl.define do
  factory :spent_finance do
    sequence :amount do |n|
      n * 99
    end

    start_date Date.new(2015, 1, 1)

    sequence :end_date do |n|
      Date.new(2015 + n, 1, 1)
    end

    association :finance_spendable, factory: :program
  end
end
