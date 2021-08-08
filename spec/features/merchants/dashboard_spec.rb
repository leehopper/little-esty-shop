require 'rails_helper'

RSpec.describe 'the merchant dashboard', :vcr do
  describe 'display' do
    it 'shows the name of the merchant and links to items and invoices index' do
      merchant1 = create(:merchant)

      visit merchant_path(merchant1.id)

      within('#header') do
        expect(page).to have_content(merchant1.name)
        expect(page).to have_selector(:link_or_button, "My Invoices")
        expect(page).to have_selector(:link_or_button, "My Items")
      end
    end

    it 'show the items that are ready to ship with their invoice and date ordered by oldest first' do
      merchant = create(:merchant, :with_items, item_count: 4)
      customer = create(:customer)

      invoice_1 = create(:invoice, customer: customer, created_at: '2018-02-13 14:53:59 UTC')
      invoice_2 = create(:invoice, customer: customer, created_at: '2015-05-25 14:53:59 UTC')
      invoice_3 = create(:invoice, customer: customer, created_at: '2010-01-24 14:53:59 UTC')
      invoice_4 = create(:invoice, customer: customer, created_at: '2015-05-25 14:53:59 UTC')

      create(:invoice_item, invoice: invoice_1, item: merchant.items.first, status: 'packaged')
      create(:invoice_item, invoice: invoice_2, item: merchant.items.second, status: 'pending')
      create(:invoice_item, invoice: invoice_3, item: merchant.items.third, status: 'packaged')
      create(:invoice_item, invoice: invoice_4, item: merchant.items.fourth, status: 'shipped')

      visit merchant_path(merchant.id)

      within('#ready_to_ship') do
        expect(page).to have_content('Items Ready to Ship')
        expect(page).to have_content(merchant.items.first.name)
        expect(page).to have_content(invoice_1.id)
        expect(page).to have_content(invoice_2.id)
        expect(page).to have_content(invoice_3.id)
        expect("Sunday, January 24, 2010").to appear_before("Tuesday, February 13, 2018")
      end
    end
  end

  describe 'hyperlinks' do
    it 'links to merchant invoice and items index' do
      merchant1 = create(:merchant)

      visit merchant_path(merchant1.id)

      within('#header') do
        click_link 'My Invoices'

        expect(current_path).to eq(merchant_invoices_path(merchant1.id))
      end

      visit merchant_path(merchant1.id)

      within('#header') do
        click_link 'My Items'

        expect(current_path).to eq(merchant_items_path(merchant1.id))
      end
    end
  end

  describe 'favorite customers' do
    it 'shows favorite customers' do
      merchant = create(:merchant)
      item1 = create(:item, merchant: merchant)
      item2 = create(:item, merchant: merchant)
      item3 = create(:item, merchant: merchant)

      customer_with_5 = create(:customer)
      c5_invoice1 = create(:invoice, :with_transactions, transaction_count: 5, customer: customer_with_5)
      create(:invoice_item, item: item1, invoice: c5_invoice1)

      customer_with_4 = create(:customer)
      c6_invoice1 = create(:invoice, :with_transactions, transaction_count: 4, customer: customer_with_4)
      create(:invoice_item, item: item2, invoice: c6_invoice1)

      customer_with_3 = create(:customer)
      c3_invoice1 = create(:invoice, :with_transactions, transaction_count: 3, customer: customer_with_3)
      create(:invoice_item, item: item2, invoice: c3_invoice1)
      create(:invoice_item, item: item3, invoice: c3_invoice1)
      create(:invoice_item, item: item1, invoice: c3_invoice1)

      customer_with_9 = create(:customer)
      c9_invoice1 = create(:invoice, :with_transactions, transaction_count: 9, customer: customer_with_9)
      create(:invoice_item, item: item2, invoice: c9_invoice1)

      customer_with_2 = create(:customer)
      c2_invoice1 = create(:invoice, customer: customer_with_2)
      create(:transaction, result: false, invoice: c2_invoice1)
      create(:transaction, result: true, invoice: c2_invoice1)
      create(:transaction, result: true, invoice: c2_invoice1)
      create(:invoice_item, item: item1, invoice: c2_invoice1)

      customer_with_1 = create(:customer)
      c1_invoice1 = create(:invoice, :with_transactions, transaction_count: 1, customer: customer_with_1)
      create(:invoice_item, item: item1, invoice: c1_invoice1)

      visit merchant_path(merchant.id)

      within('#favorite_customers') do
        expect(page).to have_content("Favorite Customers")
        expect(page).to have_content("1. #{customer_with_9.first_name} #{customer_with_9.last_name} - #{merchant.top_customers.first.total_count}")
        expect(page).to have_content("2. #{customer_with_5.first_name} #{customer_with_5.last_name} - #{merchant.top_customers.second.total_count}")
        expect(page).to have_content("3. #{customer_with_4.first_name} #{customer_with_4.last_name} - #{merchant.top_customers.third.total_count}")
        expect(page).to have_content("4. #{customer_with_3.first_name} #{customer_with_3.last_name} - #{merchant.top_customers.fourth.total_count}")
        expect(page).to have_content("5. #{customer_with_2.first_name} #{customer_with_2.last_name} - #{merchant.top_customers.last.total_count}")
      end
    end
  end
end
