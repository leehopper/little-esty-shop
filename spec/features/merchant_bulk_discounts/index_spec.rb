require 'rails_helper'

RSpec.describe 'the merchant bulk discount index', :vcr do
  before(:each) do
    @merchant = create(:merchant, :with_items_and_discounts)

    visit merchant_bulk_discounts_path(@merchant.id)
  end

  describe 'display' do
    it 'shows header information for merchant' do
      within('#header') do
        expect(page).to have_content("#{@merchant.name} Bulk Discounts Index")
      end
    end

    it 'shows all of the merchants bulk discounts and their attributes' do
      within ('#bulk_discounts') do
        @merchant.bulk_discounts.each do |discount|
          within("#discount-#{discount.id}") do
            expect(page).to have_content("Bulk Discount #{discount.id}")
            expect(page).to have_content("Quantity Threshold: #{discount.quant_threshold}")
            expect(page).to have_content("Discount: #{(discount.discount * 100)}%")
          end
        end
      end
    end
  end

  describe 'hyperlinks' do
    it 'links to bulk discount show page for each discount' do
      within ('#bulk_discounts') do
        @merchant.bulk_discounts.each do |discount|
          within("#discount-#{discount.id}") do
            click_link "#{discount.id}"

            expect(current_path).to eq(merchant_bulk_discount_path(@merchant.id, discount.id))
          end
          visit merchant_bulk_discounts_path(@merchant.id)
        end
      end
    end
  end
end
