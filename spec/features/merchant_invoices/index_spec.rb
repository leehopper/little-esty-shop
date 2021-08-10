require 'rails_helper'

RSpec.describe 'the merchant invoices index', :vcr do
  before(:each) do
    @merchant1 = create(:merchant, :with_items)
    @invoice1 = create(:invoice)
    @invoice2 = create(:invoice)
    @invoice3 = create(:invoice)
    @invoice4 = create(:invoice)
    create(:invoice_item, item: @merchant1.items.first, invoice: @invoice1)
    create(:invoice_item, item: @merchant1.items.second, invoice: @invoice2)
    create(:invoice_item, item: @merchant1.items.third, invoice: @invoice3)
    create(:invoice_item, item: @merchant1.items.first, invoice: @invoice4)
  end

  describe 'display' do
    it 'shows header text' do
      visit merchant_invoices_path(@merchant1.id)

      within('#header') do
        expect(page).to have_content(@merchant1.name)
        expect(page).to have_content('My Invoices')
      end
    end

    it 'shows all invoices that include at least one merchant item' do
      visit merchant_invoices_path(@merchant1.id)

      within("#invoice-#{@invoice1.id}") do
        expect(page).to have_content("Invoice ##{@invoice1.id}")
      end

      within("#invoice-#{@invoice2.id}") do
        expect(page).to have_content("Invoice ##{@invoice2.id}")
      end

      within("#invoice-#{@invoice3.id}") do
        expect(page).to have_content("Invoice ##{@invoice3.id}")
      end

      within("#invoice-#{@invoice4.id}") do
        expect(page).to have_content("Invoice ##{@invoice4.id}")
      end
    end

    it 'does not show invoices without one of the merchants items' do
      merchant2 = create(:merchant, :with_items)
      invoice5 = create(:invoice)
      invoice5.items << merchant2.items.first
      invoice6 = create(:invoice)
      invoice6.items << merchant2.items.second

      visit merchant_invoices_path(@merchant1.id)

      expect(page).to_not have_content(invoice5.id)
      expect(page).to_not have_content(invoice6.id)
    end
  end

  describe 'hyperlinks' do
    it 'links to the show page for each invoice' do
      visit merchant_invoices_path(@merchant1.id)

      within("#invoice-#{@invoice1.id}") do
        expect(page).to have_link("#{@invoice1.id}")
        click_link("#{@invoice1.id}")

        expect(page).to have_current_path(merchant_invoice_path(@merchant1.id, @invoice1.id))
      end

      visit merchant_invoices_path(@merchant1.id)

      within("#invoice-#{@invoice2.id}") do
        expect(page).to have_link("#{@invoice2.id}")
        click_link("#{@invoice2.id}")

        expect(page).to have_current_path(merchant_invoice_path(@merchant1.id, @invoice2.id))
      end

      visit merchant_invoices_path(@merchant1.id)

      within("#invoice-#{@invoice3.id}") do
        expect(page).to have_link("#{@invoice3.id}")
        click_link("#{@invoice3.id}")

        expect(page).to have_current_path(merchant_invoice_path(@merchant1.id, @invoice3.id))
      end

      visit merchant_invoices_path(@merchant1.id)

      within("#invoice-#{@invoice4.id}") do
        expect(page).to have_link("#{@invoice4.id}")
        click_link("#{@invoice4.id}")

        expect(page).to have_current_path(merchant_invoice_path(@merchant1.id, @invoice4.id))
      end
    end
  end
end
