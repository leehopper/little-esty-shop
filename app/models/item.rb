class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :bulk_discounts, through: :merchant
  has_many :invoices, through: :invoice_items

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true
  validates :status, presence: true

  enum status: [ :disabled, :enabled ]

  def self.enabled_items
    where(status: 'enabled')
  end

  def self.disabled_items
    where(status: 'disabled')
  end

  def best_sales_day
    invoices.joins(:transactions)
    .where(transactions: {result: true})
    .select("invoices.*, invoices.created_at as best_day, sum(invoice_items.quantity * invoice_items.unit_price) as revenue")
    .group("invoices.id")
    .order(revenue: :desc)
    .first
    .best_day
  end
end
