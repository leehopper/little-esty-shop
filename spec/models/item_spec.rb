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
        disabled_items = []
        enabled_items = []
        3.times do
          disabled_items << create(:item)
          enabled_items << create(:item, status: 'enabled')
        end

        actual = Item.enabled_items.map do |item|
          item.name
        end

        expected = enabled_items.map do |item|
          item.name
        end

        expect(actual).to eq(expected)
      end
    end

    describe '#disabled_items' do
      it 'returns merchant items with status enabled' do
        disabled_items = []
        enabled_items = []
        3.times do
          disabled_items << create(:item)
          enabled_items << create(:item, status: 'enabled')
        end

        actual = Item.disabled_items.map do |item|
          item.name
        end

        expected = disabled_items.map do |item|
          item.name
        end

        expect(actual).to eq(expected)
      end
    end
  end

  describe 'instance methods' do
    describe '#best_sales_day' do
      it 'can return date of highest sales earned' do
        merchant = create(:merchant, :with_items, item_count: 1)
        item = merchant.items.first
        customer = create(:customer)
        invoice1 = create(:invoice, :with_transactions, customer: customer, created_at: '2018-02-13 14:53:59 UTC', updated_at: '2018-02-13 14:53:59 UTC')
        invoice2 = create(:invoice, :with_transactions, customer: customer, created_at: '2015-05-25 14:53:59 UTC', updated_at: '2015-05-25 14:53:59 UTC')
        invoice3 = create(:invoice, :with_transactions, customer: customer, created_at: '2010-01-24 14:53:59 UTC', updated_at: '2010-01-24 14:53:59 UTC')
        invoice4 = create(:invoice, :with_transactions, customer: customer, created_at: '2015-05-25 14:53:59 UTC', updated_at: '2015-05-25 14:53:59 UTC')

        create(:invoice_item, item: item, invoice: invoice1)
        create(:invoice_item, item: item, invoice: invoice2)
        create(:invoice_item, item: item, invoice: invoice3)
        create(:invoice_item, item: item, invoice: invoice4)

        expect(item.best_sales_day.strftime("%m/%d/%Y")).to eq("05/25/2015")
      end
    end
  end
end
