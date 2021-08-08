class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant

  validates :discount, presence: true
  validates :discount, numericality: { only_integer: true }
  validates :quant_threshold, presence: true
  validates :quant_threshold, numericality: { only_decimal: true }
end
