require 'rails_helper'

RSpec.describe 'the merchant items show', :vcr do
  before(:each) do
    @merchant1 = create(:merchant, :with_items)
    @item1 = @merchant1.items.first
  end

  describe 'display' do
    it 'visit' do
      visit merchant_item_path(@merchant1, @item1)
    end

    it 'displays item name and its attributes' do
      visit merchant_item_path(@merchant1, @item1)

      expect(page).to have_content(@item1.name)
      expect(page).to have_content(@item1.description)
      expect(page).to have_content(@item1.unit_price)
    end
  end

  describe 'interactable elements' do
    it 'has an update link' do
      visit merchant_item_path(@merchant1, @item1)

      expect(page).to have_link("Update #{@item1.name}")
    end

    it 'can click update link and be taken to update page' do
      visit merchant_item_path(@merchant1, @item1)

      click_link("Update #{@item1.name}")

      expect(current_path).to eq(edit_merchant_item_path(@merchant1, @item1))
    end
  end
end
