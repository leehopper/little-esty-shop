class Invoice < ApplicationRecord
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :bulk_discounts, through: :items
  belongs_to :customer

  validates :status, presence: true
  enum status: [ :in_progress, :completed, :cancelled ]

  def self.incomplete_invoices_by_date
    joins(:invoice_items)
    .where.not(invoice_items: {status: :shipped})
    .select('invoices.*')
    .group(:id)
    .order(:created_at)
  end

  def total_revenue
    invoice_items.sum('quantity * unit_price')
  end

  def total_discount
    output = 0
    invoice_items.each do |ii|
      if ii.bulk_discount != nil
        output += ii.bulk_discount.discount * ii.quantity * ii.unit_price
      end
    end
    output
  end

  def total_discounted_revenue
    total_revenue - total_discount
  end
end
