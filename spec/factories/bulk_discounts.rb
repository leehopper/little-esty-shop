FactoryBot.define do
  factory :bulk_discount do
    sequence(:discount) {|n| 0.01*n }
    sequence(:quant_threshold) {|n| n }
    merchant
  end
end
