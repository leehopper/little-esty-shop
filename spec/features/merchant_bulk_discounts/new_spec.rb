require 'rails_helper'

RSpec.describe 'the merchant bulk discounts new', :vcr do
  before(:each) do
    @merchant = create(:merchant)

    visit new_merchant_bulk_discount_path(@merchant.id)
  end

  describe 'display' do
    it 'shows form to create a new bulk discount for the merchant' do
      within('#header') do
        expect(page).to have_content("Create New #{@merchant.name} Bulk Discount")
      end

      within('#form') do
        expect(page).to have_content('Discount percentage (as decimal)')
        expect(page).to have_content('Item quantity threshold')
      end
    end
  end

  describe 'fuctionality' do
    it 'creates an new bulk discount' do
      expect(@merchant.bulk_discounts.count).to eq(0)

      within('#form') do
        fill_in 'discount', with: '0.2'
        fill_in 'quant_threshold', with: '50'
        click_button 'Create'
      end

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant.id))
      expect(@merchant.bulk_discounts.count).to eq(1)
      expect(@merchant.bulk_discounts.first.discount).to eq(0.2)
      expect(@merchant.bulk_discounts.first.quant_threshold).to eq(50)
    end

    context 'error messages' do
      it 'integer instead of decimal less than 1 for discount' do
        within('#form') do
          fill_in 'discount', with: '20'
          fill_in 'quant_threshold', with: '50'
          click_button 'Create'
        end

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant.id))
        expect(page).to have_content('Error: Discount must be less than 1')
      end

      it 'not a integer for quantity threshold' do
        within('#form') do
          fill_in 'discount', with: '0.2'
          fill_in 'quant_threshold', with: '50.1'
          click_button 'Create'
        end

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant.id))
        expect(page).to have_content('Error: Quant threshold must be an integer')
      end

      it 'blank input for discount' do
        within('#form') do
          fill_in 'discount', with: ''
          fill_in 'quant_threshold', with: '50'
          click_button 'Create'
        end

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant.id))
        expect(page).to have_content("Error: Discount can't be blank, Discount is not a number")
      end

      it 'blank input for quant threshold' do
        within('#form') do
          fill_in 'discount', with: '0.1'
          fill_in 'quant_threshold', with: ''
          click_button 'Create'
        end

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant.id))
        expect(page).to have_content("Error: Quant threshold can't be blank, Quant threshold is not a number")
      end

      it 'input that is not a number' do
        within('#form') do
          fill_in 'discount', with: 'not a number'
          fill_in 'quant_threshold', with: 'not a number'
          click_button 'Create'
        end

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant.id))
        expect(page).to have_content("Error: Discount is not a number, Quant threshold is not a number")
      end
    end
  end
end
