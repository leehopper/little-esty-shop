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

    it 'displays the top 5 merchants by revenue on the show page' do
      within "#top-5-merchants-#{@merchant2.id}" do
        expect(page).to have_content(@merchant2.name)
        expect(page).to have_content("$2,740,000.00")
      end

      within "#top-5-merchants-#{@merchant1.id}" do
        expect(page).to have_content(@merchant1.name)
        expect(page).to have_content("$803,750.00")
      end

      within "#top-5-merchants-#{@merchant3.id}" do
        expect(page).to have_content(@merchant3.name)
        expect(page).to have_content("$29,900.00")
      end

      expect(@merchant2.name).to appear_before(@merchant1.name)
      expect(@merchant1.name).to appear_before(@merchant3.name)
    end

    it 'can label the date for the merchants best day for revenue' do

      within "#top-5-merchants-#{@merchant1.id}" do
        expect(page).to have_content("Top selling date for #{@merchant1.name} was #{@invoice17.created_at.strftime("%A, %B %d, %Y")}")
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
