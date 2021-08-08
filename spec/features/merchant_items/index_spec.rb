require 'rails_helper'

RSpec.describe 'the merchant items index', :vcr do
  before(:each) do
    @merchant = create(:merchant, :with_items)
    3.times do
      create(:item, status: "enabled", merchant: @merchant)
    end

    visit merchant_items_path(@merchant)
  end

  describe 'display' do
    it 'shows merchant name' do
      within('#header') do
        expect(page).to have_content("#{@merchant.name} Item Index")
      end
    end

    it 'shows enabled items as links and with a disable button' do
      within('#enabled_items') do
        @merchant.items.enabled_items.each do |item|
          expect(page).to have_link("#{item.name}")
          expect(page).to have_button("Disable #{item.name}")
        end

        @merchant.items.disabled_items.each do |item|
          expect(page).to_not have_link("#{item.name}")
        end
      end
    end

    it 'shows disabled items as links and with an enable button' do
      within('#disabled_items') do
        @merchant.items.enabled_items.each do |item|
          expect(page).to_not have_link("#{item.name}")
        end

        @merchant.items.disabled_items.each do |item|
          expect(page).to have_link("#{item.name}")
          expect(page).to have_button("Enable #{item.name}")
        end
      end
    end

    it 'shows all items for merchant and not items for other merchants' do
      new_item = create(:item)

      visit merchant_items_path(@merchant)

      @merchant.items.each do |item|
        expect(page).to have_content(item.name)
      end

      expect(page).to_not have_content(new_item.name)
    end

    it 'shows button to create a new merchant item' do
      within ('#create_item') do
        expect(page).to have_button('Create a New Item')
      end
    end
  end

  describe 'interactable elements' do
    it 'can click on item link and be taken to its show page' do
      item = @merchant.items.first

      click_link "#{item.name}"

      expect(current_path).to eq(merchant_item_path(@merchant.id, item.id))

      expect(page).to have_content("#{item.name}")
      expect(page).to have_content("#{item.description}")
      expect(page).to have_content("#{item.unit_price}")
    end

    it 'can click on enable button and enable a disabled item' do
      item = @merchant.items.disabled_items.first

      within('#enabled_items') do
        expect(page).to_not have_content(item.name)
      end

      click_button("Enable #{item.name}")

      expect(current_path).to eq(merchant_items_path(@merchant))

      within('#enabled_items') do
        expect(page).to have_content(item.name)
      end

      within('#disabled_items') do
        expect(page).to_not have_content(item.name)
      end
    end

    it 'can click on disable button and disable an enabled item' do
      item = @merchant.items.enabled_items.first

      within('#disabled_items') do
        expect(page).to_not have_content(item.name)
      end

      click_button("Disable #{item.name}")

      expect(current_path).to eq(merchant_items_path(@merchant))

      within('#disabled_items') do
        expect(page).to have_content(item.name)
      end

      within('#enabled_items') do
        expect(page).to_not have_content(item.name)
      end
    end

    it "can click on 'Create a New Item' button and be taken to the new page " do
      click_button('Create a New Item')

      expect(current_path).to eq(new_merchant_item_path(@merchant))
    end
  end
end
