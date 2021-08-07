FactoryBot.define do
  factory :invoice_item do
    invoice_id { invoice.id }
    item_id { item.id }
    sequence(:quantity) {|n| n*50 }
    unit_price { item.unit_price }
    status { 'pending' }
  end
end
