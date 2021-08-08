require 'rails_helper'

RSpec.describe 'create new merchant', :vcr do
  before :each do
    visit new_admin_merchant_path
  end

  it 'can click a link on the admin merchant index page and be taken to new form' do
    visit admin_merchants_path

    click_link("create a new merchant")

    expect(current_path).to eq(new_admin_merchant_path)
  end

  it 'can fill and create a new merchant thorugh the admin merchant path' do

    fill_in("Name", with: "Suzie")

    click_button("Create Merchant")

    expect(current_path).to eq(admin_merchants_path)

    merchant = Merchant.last

    within "#disabled-admin-merchants-#{merchant.id}" do
      expect(page).to have_content("Suzie")
    end
  end

  it 'displays error message when form submitted with blank name' do
    fill_in("Name", with: "")

    click_button("Create Merchant")

    expect(current_path).to eq(new_admin_merchant_path)
    expect(page).to have_content("Error: Name can't be blank")
  end
end
