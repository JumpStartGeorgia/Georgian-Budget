FactoryGirl.define do
  factory :name do
    sequence :text_en do |n|
      "English Name ##{n}"
    end

    sequence :text_ka do |n|
      "Georgian Name ##{n}"
    end

    sequence :start_date do |n|
      Date.new(2016, 1, 1) + n
    end

    association :nameable, factory: :program
  end
end
