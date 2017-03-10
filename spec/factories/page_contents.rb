FactoryGirl.define do
  factory :page_content do
    sequence :name do |n|
      "page content ##{n}"
    end
  end
end
