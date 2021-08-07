FactoryBot.define do
  factory :customer do
    sequence(:first_name) {|n| "First Name #{n}" }
    sequence(:last_name) {|n| "Last Name #{n}" }

    trait :with_invoices do
      transient do
        invoice_count { 3 }
      end

      after(:create) do |customer, evaluator|
        create_list(:invoice, evaluator.invoice_count, customer: customer)
      end
    end
  end
end
