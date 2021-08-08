require 'rails_helper'

RSpec.describe 'Admin Invoice Show Page', :vcr do
  before (:each) do
    @invoice = create(:invoice, :with_mixed_status_invoice_items, status: 'completed')

    visit admin_invoice_path(@invoice.id)
  end
  
  describe 'display' do
    it 'shows an invoice with attributes' do
      customer = @invoice.customer
      other_invoice = create(:invoice)
      other_customer = other_invoice.customer

      visit admin_invoice_path(@invoice.id)

      expect(page).to have_content("#{@invoice.id}")
      expect(page).to have_content("#{@invoice.status}")
      expect(page).to have_content("#{@invoice.created_at.strftime('%A, %b %d, %Y')}")
      expect(page).to have_content("#{customer.first_name}")
      expect(page).to have_content("#{customer.last_name}")

      expect(page).to_not have_content("#{other_invoice.id}")
      expect(page).to_not have_content("#{other_customer.first_name}")
      expect(page).to_not have_content("#{other_customer.last_name}")
    end

    it 'shows all items on the invoice' do
      @invoice.invoice_items.each do |invoice_item|
        within("#invoice_item-#{invoice_item.id}") do
          expect(page).to have_content("#{invoice_item.item.name}")
          expect(page).to have_content("#{invoice_item.quantity}")
          expect(page).to have_content("#{(invoice_item.unit_price/100).to_f.round(2)}")
          expect(page).to have_content("#{invoice_item.status}")
        end
      end
    end

    it 'shows the total revenue for the invoice' do
      expect(page).to have_content("Total Revenue: $#{@invoice.total_revenue/100}")
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
