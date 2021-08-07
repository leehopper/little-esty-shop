require 'rails_helper'

RSpec.describe 'the merchant items index', :vcr do
  before(:each) do
    @merchant = create(:merchant, :with_items)
    3.times do
      create(:item, status: "enabled", merchant: @merchant)
    end
  end

  describe 'display' do
    it 'shows merchant name' do
      visit merchant_items_path(@merchant)

      within('#header') do
        expect(page).to have_content("#{@merchant.name} Item Index")
      end
    end

    it 'shows enabled items' do
      visit merchant_items_path(@merchant)
      binding.pry 

      within('#enabled_items') do
        @merchant.items.enabled_items.each do |item|
          expect(page).to have_link("#{item.name}")
        end

        @merchant.items.disabled_items.each do |item|
          expect(page).to_not have_link("#{item.name}")
        end
      end
    end

    it 'displays merchant name and items' do
      new_item = create(:item)

      visit merchant_items_path(@merchant)

      @merchant.items.each do |item|
        expect(page).to have_content(item.name)
      end

      expect(page).to_not have_content(new_item.name)
    end

    it 'has item names that are links' do
      expect(page).to have_link("#{@item1.name}")
    end

    it 'has an enable button for items that are disabled' do
      expect(page).to have_button('Enable')
    end

    it 'has a disable link for items that are enabled' do
      expect(page).to_not have_button("Disable #{@item1.name}")
      click_button("Enable #{@item1.name}")

      expect(page).to have_button("Disable #{@item1.name}")
    end

    it 'has a button to make a new merchant item' do
      expect(page).to have_button('Create a New Item')
    end
  end

  describe 'interactable elements' do
    it 'can click on item link and be taken to its show page' do
      first(:link, "#{@item1.name}").click

      expect(current_path).to eq(merchant_item_path(@merchant, @item1))
      expect(page).to have_content("#{@item1.name}")
      expect(page).to have_content("#{@item1.description}")
      expect(page).to have_content("#{@item1.unit_price}")
    end

    it 'can click on enable button and enable disabled item' do
      click_button("Enable #{@item1.name}")

      expect(current_path).to eq(merchant_items_path(@merchant))
      expect('Enabled Items').to appear_before("#{@item1.name}")
      expect("#{@item1.name}").to appear_before('Disabled Items')
    end

    it "can click on 'Create a New Item' button and be taken to the new page " do
      click_button('Create a New Item')

      expect(current_path).to eq(new_merchant_item_path(@merchant))
    end
  end
end
