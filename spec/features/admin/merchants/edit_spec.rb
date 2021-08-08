require 'rails_helper'
RSpec.describe 'the admin merchant edit', :vcr do
  context 'Update an existing merchant by clicking a link on its show page' do
    before :each do
      @merchant = create(:merchant)
      visit admin_merchant_path(@merchant.id)
    end

    it 'can click on the link in the show page and be taken to the update form' do
      click_link("update #{@merchant.name}")

      expect(current_path).to eq(edit_admin_merchant_path(@merchant.id))
    end

    it 'can fill out a form to update a form for a specific merchant' do
      name = @merchant.name

      expect(page).to have_content("#{@merchant.name}")
      expect(page).to_not have_content("Costco")

      click_link("update #{@merchant.name}")

      fill_in("Name", with: "Costco")

      click_button("Update #{@merchant.name}")

      expect(current_path).to eq(admin_merchant_path(@merchant.id))
      expect(page).to have_content("Costco")
      expect(page).to_not have_content(@merchant.name)
    end

    it 'gives a flash message when you successfully update a merchant' do
      expect(page).to_not have_content("Merchant Successfully updated!")

      click_link("update #{@merchant.name}")

      fill_in("Name", with: "Costco")

      click_button("Update #{@merchant.name}")

      expect(page).to have_content("Merchant Successfully updated!")
    end

    it 'gives a flash message when you do not successfully update a merchant' do
      expect(page).to_not have_content("Error: Name can't be blank")

      click_link("update #{@merchant.name}")

      fill_in("Name", with: "")

      click_button("Update #{@merchant.name}")

      expect(page).to have_content("Error: Name can't be blank")
    end
  end
end
