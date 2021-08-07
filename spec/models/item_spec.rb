require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe 'validations' do
    context 'presence_of'
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:status) }

    context 'enum' do
      it { should define_enum_for(:status).with_values([:disabled, :enabled]) }
    end
  end

  describe 'class methods' do
    describe '#enabled_items' do
      it 'returns merchant items with status enabled' do
        merchant = create(:merchant)
        disabled_items = []
        enabled_items = []
        3.times do
          disabled_items << create(:item, merchant: merchant)
          enabled_items << create(:item, status: 'enabled', merchant: merchant)
        end

        actual = merchant.items.enabled_items.map do |item|
          item.name
        end

        expected = enabled_items.map do |item|
          item.name
        end

        expect(actual).to eq(expected)
      end
    end

    describe '#enabled_items' do
      it 'returns merchant items with status enabled' do
        merchant = create(:merchant)
        disabled_items = []
        enabled_items = []
        3.times do
          disabled_items << create(:item, merchant: merchant)
          enabled_items << create(:item, status: 'enabled', merchant: merchant)
        end

        actual = merchant.items.enabled_items.map do |item|
          item.name
        end

        expected = enabled_items.map do |item|
          item.name
        end

        expect(actual).to eq(expected)
      end
    end
  end

  describe 'instance methods' do
    describe '#best_sales_day' do
      it 'can return date of highest sales earned' do
        @merchant1 = Merchant.create!(name: 'Costco', status: "disabled")
        @customer1 = Customer.create!(first_name: 'Gunner', last_name: 'Runkle')
        @item1 = @merchant1.items.create!(name: 'Milk', description: 'A large quantity of whole milk', unit_price: 500)
        @invoice1 = @customer1.invoices.create!(status: 'completed', created_at: '2018-02-13 14:53:59 UTC', updated_at: '2018-02-13 14:53:59 UTC')
        @invoice2 = @customer1.invoices.create!(status: 'completed', created_at: '2015-05-25 14:53:59 UTC', updated_at: '2015-05-25 14:53:59 UTC')
        @invoice3 = @customer1.invoices.create!(status: 'completed', created_at: '2010-01-24 14:53:59 UTC', updated_at: '2010-01-24 14:53:59 UTC')
        @invoice4 = @customer1.invoices.create!(status: 'completed', created_at: '2015-05-25 14:53:59 UTC', updated_at: '2015-05-25 14:53:59 UTC')
        @invoice_item1 = InvoiceItem.create!(invoice_id: @invoice1.id, item_id: @item1.id, quantity: 125, unit_price: @item1.unit_price, status: 'shipped')
        @invoice_item2 = InvoiceItem.create!(invoice_id: @invoice2.id, item_id: @item1.id, quantity: 250, unit_price: @item1.unit_price, status: 'shipped')
        @invoice_item3 = InvoiceItem.create!(invoice_id: @invoice3.id, item_id: @item1.id, quantity: 1000, unit_price: @item1.unit_price, status: 'shipped')
        @invoice_item4 = InvoiceItem.create!(invoice_id: @invoice4.id, item_id: @item1.id, quantity: 500, unit_price: @item1.unit_price, status: 'shipped')
        @transaction1 = @invoice1.transactions.create!(credit_card_number: '1234234534564567', credit_card_expiration_date: nil, result: true)
        @transaction2 = @invoice2.transactions.create!(credit_card_number: '1234234534564567', credit_card_expiration_date: nil, result: true)
        @transaction3 = @invoice3.transactions.create!(credit_card_number: '1234234534564567', credit_card_expiration_date: nil, result: false)
        @transaction4 = @invoice4.transactions.create!(credit_card_number: '1234234534564567', credit_card_expiration_date: nil, result: true)

        expect(@item1.best_sales_day.strftime("%m/%d/%Y")).to eq("05/25/2015")
      end
    end
  end
end
