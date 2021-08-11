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

  def bulk_discount
    bulk_discounts.where('quant_threshold <= ?', quantity)
                  .order(discount: :desc)
                  .first
  end
end
