FactoryBot.define do
  factory :bulk_discount do
    sequence(:discount) {|n| 0.01*n }
    sequence(:quant_threshold) {|n| 10*n }
    merchant
  end
end
