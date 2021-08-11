require 'rails_helper'

RSpec.describe 'the merchants index', :vcr do
  before(:each) do
    3.times do
      create(:merchant)
    end

    visit merchants_path
  end

  describe 'display' do
    it 'displays each merchant' do
      Merchant.all.each do |merchant|
        expect(page).to have_content("Merchant #{merchant.name}")
      end
    end
  end

  describe 'hyperlinks' do
    it 'links to each merchant show page' do
      Merchant.all.each do |merchant|
        click_link "#{merchant.name}"

        expect(current_path).to eq(merchant_path(merchant.id))

        visit merchants_path
      end
    end
  end
end
