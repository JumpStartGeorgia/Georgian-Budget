FactoryGirl.define do
  factory :spent_finance do
    sequence :amount do |n|
      n * 99
    end

    sequence :start_date do |n|
      Month.for_date(Date.new(2015 + n, 1, 1)).start_date
    end

    sequence :end_date do |n|
      Month.for_date(Date.new(2015 + n, 1, 1)).end_date
    end

    association :finance_spendable, factory: :program
  end
end
