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

    trait :with_pending_invoice_items do
      transient do
        invoice_item_count { 3 }
      end

      after(:create) do |invoice, evaluator|
        create_list(:invoice_item, evaluator.invoice_item_count, invoice: invoice)
      end
    end

    trait :with_packaged_invoice_items do
      transient do
        invoice_item_count { 3 }
      end

      after(:create) do |invoice, evaluator|
        create_list(:invoice_item, evaluator.invoice_item_count, invoice: invoice, status: 'packaged')
      end
    end

    trait :with_shipped_invoice_items do
      transient do
        invoice_item_count { 3 }
      end

      after(:create) do |invoice, evaluator|
        create_list(:invoice_item, evaluator.invoice_item_count, invoice: invoice, status: 'shipped')
      end
    end

    trait :with_mixed_status_invoice_items do
      transient do
        invoice_item_count { 2 }
      end

      after(:create) do |invoice, evaluator|
        create_list(:invoice_item, evaluator.invoice_item_count, invoice: invoice)
        create_list(:invoice_item, evaluator.invoice_item_count, invoice: invoice, status: 'packaged')
        create_list(:invoice_item, evaluator.invoice_item_count, invoice: invoice, status: 'shipped')
      end
    end
  end
end
