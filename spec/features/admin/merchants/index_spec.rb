require 'rails_helper'

RSpec.describe 'it shows the merchant index page', :vcr do
  before :each do
    5.times do
      create(:merchant)
      create(:merchant, status: 'disabled')
    end

    visit admin_merchants_path
  end

  describe 'display' do
    it 'displays header and link to create a new merchant' do
      expect(page).to have_content('All Merchants')

      expect(page).to have_link("create a new merchant")
    end

    it 'shows the names of the of all the merchants' do
      Merchant.all.each do |merchant|
        expect(page).to have_content(merchant.name)
      end
    end

    it 'classifies the merchant names in labeled sections, shows the enabled merchants section' do
      Merchant.enabled_merchants.each do |merchant|
        within "#enabled-admin-merchants-#{merchant.id}" do
          expect(page).to have_content(merchant.name)
        end
      end
    end

    it 'classifies the merchant names in labeled sections, shows the disabled merchants section' do
      Merchant.disabled_merchants.each do |merchant|
        within "#disabled-admin-merchants-#{merchant.id}" do
          expect(page).to have_content(merchant.name)
        end
      end
    end

    it 'shows an enable button for each merchant on the index page' do
      Merchant.enabled_merchants.each do |merchant|
        within "#enabled-admin-merchants-#{merchant.id}" do
          expect(page).to have_selector(:button, "Disable")
        end
      end

      Merchant.disabled_merchants.each do |merchant|
        within "#disabled-admin-merchants-#{merchant.id}" do
          expect(page).to have_selector(:button, "Enable")
        end
      end
    end

    it 'shows the top 5 merchants by revenue and their best day of sales' do
      merchant_5 = create(:merchant, :with_items, item_count: 1)
      m5_invoice_item = create(:invoice_item, item: merchant_5.items.first, quantity: 1, unit_price: 100)
      create(:transaction, invoice: m5_invoice_item.invoice)

      merchant_1 = create(:merchant, :with_items, item_count: 1)
      m1_invoice_item = create(:invoice_item, item: merchant_1.items.first, quantity: 10, unit_price: 100)
      create(:transaction, invoice: m1_invoice_item.invoice)

      merchant_3 = create(:merchant, :with_items, item_count: 3)
      m3_invoice_item_1 = create(:invoice_item, item: merchant_3.items.first, quantity: 1, unit_price: 100)
      m3_invoice_item_2 = create(:invoice_item, item: merchant_3.items.second, quantity: 1, unit_price: 100)
      m3_invoice_item_3 = create(:invoice_item, item: merchant_3.items.last, quantity: 6, unit_price: 100)
      create(:transaction, invoice: m3_invoice_item_1.invoice)
      create(:transaction, invoice: m3_invoice_item_2.invoice)
      create(:transaction, invoice: m3_invoice_item_3.invoice)

      merchant_2 = create(:merchant, :with_items, item_count: 1)
      m2_invoice_item = create(:invoice_item, item: merchant_2.items.first, quantity: 9, unit_price: 100)
      create(:transaction, invoice: m2_invoice_item.invoice)

      merchant_4 = create(:merchant, :with_items, item_count: 1)
      m4_invoice_item = create(:invoice_item, item: merchant_4.items.first, quantity: 5, unit_price: 100)
      create(:transaction, invoice: m4_invoice_item.invoice)

      not_expected_merchant = create(:merchant, :with_items, item_count: 1)
      ne_invoice_item = create(:invoice_item, item: not_expected_merchant.items.first, quantity: 1, unit_price: 50)
      create(:transaction, invoice: ne_invoice_item.invoice)

      visit admin_merchants_path

      Merchant.top_5_merchants_revenue.each do |merchant|
        within "#top-5-merchants-#{merchant.id}" do
          expect(page).to have_content(merchant.name)
          expect(page).to have_content("$#{(merchant.revenue / 100)}.00")
          expect(page).to have_content("Top selling date for #{merchant.name} was #{merchant.merchant_best_day.strftime("%A, %B %d, %Y")}")
        end
      end
    end
  end

  describe 'functionality' do
    it 'can click create a new merchant link and go to new merchant page' do
      click_link 'create a new merchant'

      expect(current_path).to eq(new_admin_merchant_path)
    end

    it 'can click the enable button for a merchant and change its status to enabled' do
      Merchant.disabled_merchants.each do |merchant|
        within "#disabled-admin-merchants-#{merchant.id}" do
          click_button("Enable")
        end

        within "#enabled-admin-merchants-#{merchant.id}" do
          expect(page).to have_content(merchant.name)
        end

        visit admin_merchants_path
      end
    end

    it 'can click the disable button for a merchant and change its status to disabled' do
      Merchant.enabled_merchants.each do |merchant|
        within "#enabled-admin-merchants-#{merchant.id}" do
          click_button("Disable")
        end

        within "#disabled-admin-merchants-#{merchant.id}" do
          expect(page).to have_content(merchant.name)
        end

        visit admin_merchants_path
      end
    end
  end
end
