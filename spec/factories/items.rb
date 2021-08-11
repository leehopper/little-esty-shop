FactoryBot.define do
  factory :item do
    sequence(:name) {|n| "Item #{n}" }
    sequence(:description) {|n| "Item #{n} Description" }
    sequence(:unit_price) {|n| n*9 }
    merchant
  end
end
