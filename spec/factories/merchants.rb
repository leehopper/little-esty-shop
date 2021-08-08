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

    trait :with_items_and_discounts do
      transient do
        item_count { 3 }
        discount_count { 3 }
      end

      after(:create) do |merchant, evaluator|
        create_list(:item, evaluator.item_count, merchant: merchant)
        create_list(:bulk_discount, evaluator.discount_count, merchant: merchant)
      end
    end
  end
end
