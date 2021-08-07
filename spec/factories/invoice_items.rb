FactoryBot.define do
  factory :invoice_item do
    sequence(:quantity) {|n| n*50 }
    unit_price { item.unit_price }
    status { 'pending' }
    invoice
    item
  end
end
