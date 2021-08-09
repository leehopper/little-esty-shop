class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant

  validates_presence_of :discount, :quant_threshold

  validates :discount, numericality: { only_decimal: true, greater_than: 0, less_than: 1 }
  validates :quant_threshold, numericality: { only_integer: true }
end
