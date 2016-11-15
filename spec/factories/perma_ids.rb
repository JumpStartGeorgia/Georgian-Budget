FactoryGirl.define do
  factory :perma_id do
    sequence :text do |n|
      "perma_id_text_#{n}"
    end

    association :perma_idable, factory: :program
  end
end
