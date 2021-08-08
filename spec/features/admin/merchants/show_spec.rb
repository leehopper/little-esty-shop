require 'rails_helper'

RSpec.describe 'the admin merchant show page', :vcr do
  before :each do
    @merchant = create(:merchant)
  end

  describe 'display' do
    it 'displays merchant name' do
      visit admin_merchant_path(@merchant.id)

      expect(page).to have_content("#{@merchant.name}'s show page")
      expect(page).to have_content("Name: #{@merchant.name}")
    end

    it 'displays link to update merchant' do
      visit admin_merchant_path(@merchant.id)

      expect(page).to have_link("update #{@merchant.name}")
    end
  end

  describe 'functionality' do
    it 'can click the link on the index page of a certain merchant and be taken to its show page' do
      visit admin_merchants_path

      within "#enabled-admin-merchants-#{@merchant.id}" do
        click_link(@merchant.name)
      end

      expect(current_path).to eq(admin_merchant_path(@merchant.id))
    end

    it 'shows the name of the merchant on the Show page' do
      merchant2 = create(:merchant)

      visit admin_merchant_path(@merchant.id)

      expect(page).to have_content(@merchant.name)
      expect(page).to_not have_content(merchant2.name)
    end

    it 'links to update merchant page' do
      visit admin_merchant_path(@merchant.id)

      click_link "update #{@merchant.name}"

      expect(current_path).to eq(edit_admin_merchant_path(@merchant.id))
    end
  end
end
