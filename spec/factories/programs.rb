FactoryGirl.define do
  factory :program do
    # sequence :code do |n|
    #   "01 #{n.to_s}"
    # end

    factory :program_with_name do
      transient do
        names_count 1
      end

      after(:create) do |program, evaluator|
        create_list(:name, evaluator.names_count, nameable: program)
      end
    end
  end
end
