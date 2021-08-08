require 'rails_helper'

RSpec.describe 'the merchant invoice show', :vcr do
  before(:each) do
    @merchant1 = create(:merchant, :with_items)
    @invoice1 = create(:invoice)
    @invoice_item1 = create(:invoice_item, item: @merchant1.items.first, invoice: @invoice1)
  end

  describe 'display' do
    it 'shows header text merchant name and invoice id' do
      visit merchant_invoice_path(@merchant1.id, @invoice1.id)

      within('#header') do
        expect(page).to have_content(@merchant1.name)
        expect(page).to have_content("Invoice ##{@invoice1.id}")
      end
    end

    it 'shows status, created on, and total revenue' do
      visit merchant_invoice_path(@merchant1.id, @invoice1.id)

      within('#invoice_info') do
        expect(page).to have_content("Status: #{@invoice1.status}")
        expect(page).to have_content("Created on: #{@invoice1.created_at.strftime("%A, %B %d, %Y")}")
        expect(page).to have_content("Total Revenue: $#{(@invoice1.total_revenue / 100)}.00")
      end
    end

    it 'shows customer header and name' do
      visit merchant_invoice_path(@merchant1.id, @invoice1.id)

      within('#customer') do
        expect(page).to have_content('Customer:')
        expect(page).to have_content("#{@invoice1.customer.first_name} #{@invoice1.customer.last_name}")
      end
    end

    it 'shows all items on invoice and their attributes' do
      invoice_item2 = create(:invoice_item, item: @merchant1.items.second, invoice: @invoice1)
      invoice_item3 = create(:invoice_item, item: @merchant1.items.third, invoice: @invoice1)

      visit merchant_invoice_path(@merchant1.id, @invoice1.id)

      within('#items') do
        expect(page).to have_content('Items on this Invoice:')

        within("#item-#{@merchant1.items.first.id}") do
          expect(page).to have_content("Item Name: #{@merchant1.items.first.name}")
          expect(page).to have_content("Quantity: #{@invoice_item1.quantity}")
          expect(page).to have_content("Unit Price: #{@invoice_item1.unit_price}")
          expect(page).to have_select('invoice_item[status]', selected: @invoice_item1.status)
        end

        within("#item-#{@merchant1.items.second.id}") do
          expect(page).to have_content("Item Name: #{@merchant1.items.second.name}")
          expect(page).to have_content("Quantity: #{invoice_item2.quantity}")
          expect(page).to have_content("Unit Price: #{invoice_item2.unit_price}")
          expect(page).to have_select('invoice_item[status]', selected: invoice_item2.status)
        end

        within("#item-#{@merchant1.items.third.id}") do
          expect(page).to have_content("Item Name: #{@merchant1.items.third.name}")
          expect(page).to have_content("Quantity: #{invoice_item3.quantity}")
          expect(page).to have_content("Unit Price: #{invoice_item3.unit_price}")
          expect(page).to have_select('invoice_item[status]', selected: invoice_item3.status)
        end
      end
    end

    it 'does not show item info not on invoice' do
      other_merchant = create(:merchant, :with_items)

      visit merchant_invoice_path(@merchant1.id, @invoice1.id)

      expect(page).to_not have_content(other_merchant.items.first.name)
      expect(page).to_not have_content(other_merchant.items.second.name)
    end
  end

  describe 'forms' do
    it 'can select a new status, submit form, and see the updated status' do
      visit merchant_invoice_path(@merchant1.id, @invoice1.id)

      within("#item-#{@merchant1.items.first.id}") do
        expect(@invoice_item1.status).to_not eq('packaged')

        page.select 'packaged', from: 'invoice_item[status]'
        click_button 'Update Item Status'
      end

      expect(current_path).to eq(merchant_invoice_path(@merchant1.id, @invoice1.id))

      within("#item-#{@merchant1.items.first.id}") do
        updated_invoice_item = InvoiceItem.find(@invoice_item1.id)

        expect(updated_invoice_item.status).to eq('packaged')

        expect(page).to have_select('invoice_item[status]', selected: 'packaged')
      end
    end
  end
end
