FactoryBot.define do
  factory :merchant do
    sequence(:name) {|n| "Merchant #{n}" }
    status { 'enabled' }

    trait :with_items do
      transient do
        item_count { 3 }
      end

      after(:create) do |merchant, evaluator|
        create_list(:item, evaluator.item_count, merchant: merchant)
      end
    end
  end
end
