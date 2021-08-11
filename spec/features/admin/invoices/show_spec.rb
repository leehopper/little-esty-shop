require 'rails_helper'

RSpec.describe 'the admin invoice show', :vcr do
  before (:each) do
    @invoice = create(:invoice, status: 'completed')

    3.times do
      merchant = create(:merchant, :with_items_and_discounts)
      create(:invoice_item, item: merchant.items.first, invoice: @invoice, quantity: 15)
      create(:invoice_item, item: merchant.items.second, invoice: @invoice, quantity: 20)
      create(:invoice_item, item: merchant.items.third, invoice: @invoice, quantity: 25)
    end

    visit admin_invoice_path(@invoice.id)
  end

  describe 'display' do
    it 'shows an invoice with attributes' do
      customer = @invoice.customer
      other_invoice = create(:invoice)
      other_customer = other_invoice.customer

      visit admin_invoice_path(@invoice.id)

      within('#header_attributes') do
        expect(page).to have_content("Invoice ID: #{@invoice.id}")
        expect(page).to have_content("#{@invoice.status}")
        expect(page).to have_content("Created At: #{@invoice.created_at.strftime('%A, %b %d, %Y')}")
        expect(page).to have_content("Customer: #{customer.first_name} #{customer.last_name}")

        expect(page).to_not have_content("#{other_invoice.id}")
        expect(page).to_not have_content("#{other_customer.first_name}")
        expect(page).to_not have_content("#{other_customer.last_name}")
      end
    end

    it 'shows all items on the invoice' do
      @invoice.invoice_items.each do |invoice_item|
        within("#invoice_item-#{invoice_item.id}") do
          expect(page).to have_content("Item Name: #{invoice_item.item.name}")
          expect(page).to have_content("Quantity: #{invoice_item.quantity}")
          expect(page).to have_content("Unit Price: $#{(invoice_item.unit_price/100).to_f.round(2)}")
          expect(page).to have_content("Status: #{invoice_item.status}")
        end
      end
    end

    it 'shows the total revenue for the invoice' do
      within('#revenue') do
        expect(page).to have_content("Total Revenue: $#{(@invoice.total_revenue / 100).to_f.round(2)}")
      end
    end

    it 'shows the total discounted revenue for the invoice' do
      within('#revenue') do
        expect(page).to have_content("Total Discounted Revenue: $#{(@invoice.total_discounted_revenue / 100).to_f.round(2)}")
      end
    end
  end

  describe 'functionality' do
    it 'can select a new status, submit form, and see the updated status' do
      expect(page).to have_select(:status, selected: 'completed')
      expect(@invoice.status).to_not eq('in_progress')

      page.select 'in_progress', from: :status
      click_button 'Update Invoice Status'

      expect(current_path).to eq(admin_invoice_path(@invoice.id))

      updated_invoice = Invoice.find(@invoice.id)

      expect(updated_invoice.status).to eq('in_progress')
      expect(page).to have_select(:status, selected: 'in_progress')
    end
  end
end
