require 'rails_helper'

RSpec.describe 'the merchant bulk discounts new', :vcr do
  before(:each) do
    @merchant = create(:merchant)
    @discount = create(:bulk_discount, merchant: @merchant)

    visit edit_merchant_bulk_discount_path(@merchant.id, @discount.id)
  end

  describe 'display' do
    it 'shows form to edit bulk discount prepopulated with current data' do
      within('#header') do
        expect(page).to have_content("Edit #{@merchant.name}'s Bulk Discount #{@discount.id}")
      end

      within('#form') do
        expect(page).to have_content('Discount percentage (as decimal)')
        expect(page).to have_field('bulk_discount_discount', with: "#{@discount.discount}")
        expect(page).to have_content('Item quantity threshold')
        expect(page).to have_field('bulk_discount_quant_threshold', with: "#{@discount.quant_threshold}")
      end
    end
  end

  describe 'fuctionality' do
    it "updates a bulk discount's discount" do
      unchanged_quant_threshold = @discount.quant_threshold

      expect(@discount.discount).to_not eq(0.9999)

      within('#form') do
        fill_in 'bulk_discount_discount', with: '0.9999'
        click_button 'Update'
      end

      updated_discount = BulkDiscount.find(@discount.id)

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant.id))
      expect(updated_discount.discount).to eq(0.9999)
      expect(updated_discount.quant_threshold).to eq(unchanged_quant_threshold)
    end

    it "updates a bulk discount's quantity threshold" do
      unchanged_discount = @discount.discount

      expect(@discount.quant_threshold).to_not eq(999999999)

      within('#form') do
        fill_in 'bulk_discount_quant_threshold', with: '999999999'
        click_button 'Update'
      end

      updated_discount = BulkDiscount.find(@discount.id)

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant.id))
      expect(updated_discount.quant_threshold).to eq(999999999)
      expect(updated_discount.discount).to eq(unchanged_discount)
    end

    context 'error messages' do
      it 'integer instead of decimal less than 1 for discount' do
        within('#form') do
          fill_in 'bulk_discount_discount', with: '20'
          fill_in 'bulk_discount_quant_threshold', with: '50'
          click_button 'Update'
        end

        expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant.id, @discount.id))
        expect(page).to have_content('Error: Discount must be less than 1')
      end

      it 'not a integer for quantity threshold' do
        within('#form') do
          fill_in 'bulk_discount_discount', with: '0.2'
          fill_in 'bulk_discount_quant_threshold', with: '50.1'
          click_button 'Update'
        end

        expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant.id, @discount.id))
        expect(page).to have_content('Error: Quant threshold must be an integer')
      end

      it 'blank input for bulk_discount_discount' do
        within('#form') do
          fill_in 'bulk_discount_discount', with: ''
          fill_in 'bulk_discount_quant_threshold', with: '50'
          click_button 'Update'
        end

        expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant.id, @discount.id))
        expect(page).to have_content("Error: Discount can't be blank, Discount is not a number")
      end

      it 'blank input for quant threshold' do
        within('#form') do
          fill_in 'bulk_discount_discount', with: '0.1'
          fill_in 'bulk_discount_quant_threshold', with: ''
          click_button 'Update'
        end

        expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant.id, @discount.id))
        expect(page).to have_content("Error: Quant threshold can't be blank, Quant threshold is not a number")
      end

      it 'input that is not a number' do
        within('#form') do
          fill_in 'bulk_discount_discount', with: 'not a number'
          fill_in 'bulk_discount_quant_threshold', with: 'not a number'
          click_button 'Update'
        end

        expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant.id, @discount.id))
        expect(page).to have_content("Error: Discount is not a number, Quant threshold is not a number")
      end
    end
  end
end
