class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  has_many :bulk_discounts, through: :item

  enum status: [:pending, :packaged, :shipped]

  def self.locate(invoice_id, item_id)
    where('invoice_id = ?', invoice_id).where('item_id = ?', item_id).first
  end

  def self.total_revenue
    sum("quantity * unit_price")
  end

  def discount
    output = 0
    if bulk_discounts.count >= 1
      best_discount = bulk_discounts.first.discount
      bulk_discounts.each do |discount|
        if quantity >= discount.quant_threshold && discount.discount >= best_discount
          output = (quantity * unit_price * discount.discount).to_f
          best_discount = discount.discount
        end
      end
    end
    output
  end
end
