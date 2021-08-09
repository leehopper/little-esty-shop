require 'rails_helper'

RSpec.describe 'the merchant bulk discounts index', :vcr do
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
        expect(page).to have_content("Merchant Discounts:")

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

  describe 'functionality' do
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

    describe 'buttons' do
      it 'links to create a new discount form and adds the discount to merchant' do
        expect(page).to_not have_content('Discount: 99.99%')

        within('#buttons') do
          click_button 'Create a new discount'
        end

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant.id))

        fill_in 'discount', with: '0.9999'
        fill_in 'quant_threshold', with: '10'
        click_button 'Create'

        expect(current_path).to eq(merchant_bulk_discounts_path(@merchant.id))
        expect(page).to have_content('Discount: 99.99%')
      end

      it 'delete button for each discount deletes the discount' do
        within ('#bulk_discounts') do
          @merchant.bulk_discounts.each do |discount|
            within("#discount-#{discount.id}") do
              click_button "Delete"

              expect(current_path).to eq(merchant_bulk_discounts_path(@merchant.id))
            end

            expect(page).to_not have_content("Bulk Discount #{discount.id}")
          end
        end

        expect(@merchant.bulk_discounts.count).to eq(0)
      end

      it 'edit button for each discount edits the discount and quantity threshold' do
        @merchant.bulk_discounts.first(2).each do |discount|
          within("#discount-#{discount.id}") do
            expect(page).to_not have_content('Discount: 99.99%')
            expect(page).to_not have_content('Quantity Threshold: 999999999')

            click_button "Edit"

            expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant.id, discount.id))
          end

          expect(page).to have_content("Edit #{@merchant.name}'s Bulk Discount #{discount.id}")

          within('#form') do
            fill_in 'bulk_discount_discount', with: '0.9999'
            fill_in 'bulk_discount_quant_threshold', with: '999999999'
            click_button 'Update'
          end

          expect(current_path).to eq(merchant_bulk_discounts_path(@merchant.id))

          within("#discount-#{discount.id}") do
            expect(page).to have_content('Discount: 99.99%')
            expect(page).to have_content("Quantity Threshold: 999999999")
          end
        end
      end
    end
  end


  describe 'api calls' do
    it 'displays the next 3 holidays in the USA and their dates' do
      within('#holidays') do
        expect(page).to have_content('Upcoming Holidays in the United States')
        expect(page).to have_content('Labour Day - Monday, September 6, 2021')
        expect(page).to have_content('Columbus Day - Monday, October 11, 2021')
        expect(page).to have_content('Veterans Day - Thursday, November 11, 2021')
      end
    end
  end
end
