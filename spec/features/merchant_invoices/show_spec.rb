require 'rails_helper'

RSpec.describe 'the merchant invoice show', :vcr do
  before(:each) do
    @merchant = create(:merchant)
    @invoice = create(:invoice)

    @item_1 = create(:item, merchant: @merchant, unit_price: 1000)
    @item_2 = create(:item, merchant: @merchant, unit_price: 100)
    @item_3 = create(:item, merchant: @merchant, unit_price: 300)

    @invoice_item_1 = create(:invoice_item, item: @item_1, invoice: @invoice, quantity: 5)
    @invoice_item_2 = create(:invoice_item, item: @item_2, invoice: @invoice, quantity: 25)
    @invoice_item_3 = create(:invoice_item, item: @item_3, invoice: @invoice, quantity: 50)

    @bulk_discount_1 = create(:bulk_discount, merchant: @merchant, discount: 0.2, quant_threshold: 20)
    @bulk_discount_2 = create(:bulk_discount, merchant: @merchant, discount: 0.5, quant_threshold: 50)

    visit merchant_invoice_path(@merchant.id, @invoice.id)
  end

  describe 'display' do
    it 'shows header text merchant name and invoice id' do
      within('#header') do
        expect(page).to have_content(@merchant.name)
        expect(page).to have_content("Invoice ##{@invoice.id}")
      end
    end

    it 'shows status and created on' do
      within('#invoice_info') do
        expect(page).to have_content("Status: #{@invoice.status}")
        expect(page).to have_content("Created on: #{@invoice.created_at.strftime("%A, %B %d, %Y")}")
      end
    end

    it 'shows total revenue and total discounted revenue' do
      within('#invoice_info') do
        expect(page).to have_content("Total Revenue: $#{(@invoice.total_revenue / 100)}.00")
        expect(page).to have_content("Total Discounted Revenue: $#{(@invoice.total_discounted_revenue / 100)}")
      end
    end

    it 'shows customer header and name' do
      within('#customer') do
        expect(page).to have_content('Customer:')
        expect(page).to have_content("#{@invoice.customer.first_name} #{@invoice.customer.last_name}")
      end
    end

    it 'shows all items on invoice and their attributes' do
      within('#items') do
        expect(page).to have_content('Items on this Invoice:')

        within("#item-#{@item_1.id}") do
          expect(page).to have_content("Item Name: #{@item_1.name}")
          expect(page).to have_content("Quantity: #{@invoice_item_1.quantity}")
          expect(page).to have_content("Unit Price: $#{@invoice_item_1.unit_price / 100}")
          expect(page).to_not have_content("Bulk Discount:")
          expect(page).to have_select('invoice_item[status]', selected: @invoice_item_1.status)
        end

        within("#item-#{@item_2.id}") do
          expect(page).to have_content("Item Name: #{@item_2.name}")
          expect(page).to have_content("Quantity: #{@invoice_item_2.quantity}")
          expect(page).to have_content("Unit Price: $#{@invoice_item_2.unit_price / 100}")
          expect(page).to have_content("Bulk Discount: #{@bulk_discount_1.id}")
          expect(page).to have_select('invoice_item[status]', selected: @invoice_item_2.status)
        end

        within("#item-#{@item_3.id}") do
          expect(page).to have_content("Item Name: #{@item_3.name}")
          expect(page).to have_content("Quantity: #{@invoice_item_3.quantity}")
          expect(page).to have_content("Unit Price: $#{@invoice_item_3.unit_price / 100}")
          expect(page).to have_content("Bulk Discount: #{@bulk_discount_2.id}")
          expect(page).to have_select('invoice_item[status]', selected: @invoice_item_3.status)
        end
      end
    end

    it 'does not show item info not on invoice' do
      other_merchant = create(:merchant, :with_items)

      visit merchant_invoice_path(@merchant.id, @invoice.id)

      expect(page).to_not have_content(other_merchant.items.first.name)
      expect(page).to_not have_content(other_merchant.items.second.name)
    end
  end

  describe 'hyperlinks' do
    it 'links to the show page for each displayed bulk discount id' do
      within("#item-#{@item_2.id}") do
        expect(page).to have_content("Bulk Discount: #{@bulk_discount_1.id}")

        click_link "#{@bulk_discount_1.id}"
      end

      expect(current_path).to eq(merchant_bulk_discount_path(@merchant.id, @bulk_discount_1.id))

      visit merchant_invoice_path(@merchant.id, @invoice.id)

      within("#item-#{@item_3.id}") do
        expect(page).to have_content("Bulk Discount: #{@bulk_discount_2.id}")

        click_link "#{@bulk_discount_2.id}"
      end

      expect(current_path).to eq(merchant_bulk_discount_path(@merchant.id, @bulk_discount_2.id))
    end
  end

  describe 'forms' do
    it 'can select a new status, submit form, and see the updated status' do
      within("#item-#{@item_1.id}") do
        expect(@invoice_item_1.status).to_not eq('packaged')

        page.select 'packaged', from: 'invoice_item[status]'
        click_button 'Update Item Status'
      end

      expect(current_path).to eq(merchant_invoice_path(@merchant.id, @invoice.id))

      within("#item-#{@merchant.items.first.id}") do
        updated_invoice_item = InvoiceItem.find(@invoice_item_1.id)

        expect(updated_invoice_item.status).to eq('packaged')

        expect(page).to have_select('invoice_item[status]', selected: 'packaged')
      end
    end
  end
end
