require 'rails_helper'

RSpec.describe 'the merchant bulk discount index', :vcr do
  before(:each) do
    @merchant = create(:merchant, :with_items_and_discounts)
  end

  describe 'display' do
    it 'shows all of the merchants bulk discounts and their attributes' do

    end
  end
end
