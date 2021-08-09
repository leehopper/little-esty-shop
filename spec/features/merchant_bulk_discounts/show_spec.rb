require 'rails_helper'

RSpec.describe 'the merchant bulk discounts show', :vcr do
  describe 'display' do
    it 'shows the bulk discount id and attributes' do
      discount = create(:bulk_discount)

      visit merchant_bulk_discount_path(discount.merchant.id, discount.id)

      expect(page).to have_content("Bulk Discount #{discount.id}")
      expect(page).to have_content("Quantity Threshold: #{discount.quant_threshold}")
      expect(page).to have_content("Discount: #{(discount.discount * 100)}%")
    end
  end
end
