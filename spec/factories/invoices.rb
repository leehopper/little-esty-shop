FactoryBot.define do
  factory :invoice do
    status { 'completed' }
    customer

    trait :with_transactions do
      transient do
        transaction_count { 1 }
      end

      after(:create) do |invoice, evaluator|
        create_list(:transaction, evaluator.transaction_count, invoice: invoice)
      end
    end
  end
end
