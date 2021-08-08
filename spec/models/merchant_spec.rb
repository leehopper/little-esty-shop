require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:items) }
    it { should have_many(:invoice_items).through(:items) }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should have_many(:transactions).through(:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'instance methods' do
    describe '#top_customers' do
      it 'returns the top 5 customers by succussesful transactions' do
        merchant = create(:merchant)
        item1 = create(:item, merchant: merchant)
        item2 = create(:item, merchant: merchant)
        item3 = create(:item, merchant: merchant)

        customer_with_5 = create(:customer)
        c5_invoice1 = create(:invoice, :with_transactions, transaction_count: 5, customer: customer_with_5)
        create(:invoice_item, item: item1, invoice: c5_invoice1)

        customer_with_4 = create(:customer)
        c6_invoice1 = create(:invoice, :with_transactions, transaction_count: 4, customer: customer_with_4)
        create(:invoice_item, item: item2, invoice: c6_invoice1)

        customer_with_3 = create(:customer)
        c3_invoice1 = create(:invoice, :with_transactions, transaction_count: 3, customer: customer_with_3)
        create(:invoice_item, item: item2, invoice: c3_invoice1)
        create(:invoice_item, item: item3, invoice: c3_invoice1)
        create(:invoice_item, item: item1, invoice: c3_invoice1)

        customer_with_9 = create(:customer)
        c9_invoice1 = create(:invoice, :with_transactions, transaction_count: 9, customer: customer_with_9)
        create(:invoice_item, item: item2, invoice: c9_invoice1)

        customer_with_2 = create(:customer)
        c2_invoice1 = create(:invoice, customer: customer_with_2)
        create(:transaction, result: false, invoice: c2_invoice1)
        create(:transaction, result: true, invoice: c2_invoice1)
        create(:transaction, result: true, invoice: c2_invoice1)
        create(:invoice_item, item: item1, invoice: c2_invoice1)

        customer_with_1 = create(:customer)
        c1_invoice1 = create(:invoice, :with_transactions, transaction_count: 1, customer: customer_with_1)
        create(:invoice_item, item: item1, invoice: c1_invoice1)

        actual = merchant.top_customers.map do |customer|
          customer.first_name
        end

        expected = [customer_with_9, customer_with_5, customer_with_4, customer_with_3, customer_with_2].map do |customer|
          customer.first_name
        end

        expect(actual).to eq(expected)
      end
    end
  end

  describe 'class methods' do
   describe '.enabled_merchants' do
      it 'can get all the merchants that are enabled' do
        e_merchant_1 = create(:merchant)
        e_merchant_2 = create(:merchant)
        e_merchant_3 = create(:merchant)
        d_merchant_1 = create(:merchant, status: 'disabled')

        expect(Merchant.enabled_merchants).to eq([e_merchant_1, e_merchant_2, e_merchant_3])

        expect(Merchant.enabled_merchants).to_not include(d_merchant_1)
      end
    end

    describe '.disabled_merchants' do
      it 'can get all the merchants that are disabled' do
        e_merchant_1 = create(:merchant)
        e_merchant_2 = create(:merchant)
        e_merchant_3 = create(:merchant)
        d_merchant_1 = create(:merchant, status: 'disabled')
        d_merchant_2 = create(:merchant, status: 'disabled')
        d_merchant_3 = create(:merchant, status: 'disabled')

        expect(Merchant.disabled_merchants).to eq([d_merchant_1, d_merchant_2, d_merchant_3])

        expect(Merchant.disabled_merchants).to_not include(e_merchant_1)
      end
    end

    describe '.top_5_merchants_revenue' do
      it 'can get the top 5 merchants by their revenue based off of successful transactions' do
        merchant_5 = create(:merchant, :with_items, item_count: 1)
        m5_invoice_item = create(:invoice_item, item: merchant_5.items.first, quantity: 1, unit_price: 10)
        create(:transaction, invoice: m5_invoice_item.invoice)

        merchant_1 = create(:merchant, :with_items, item_count: 1)
        m1_invoice_item = create(:invoice_item, item: merchant_1.items.first, quantity: 10, unit_price: 10)
        create(:transaction, invoice: m1_invoice_item.invoice)

        merchant_3 = create(:merchant, :with_items, item_count: 3)
        m3_invoice_item_1 = create(:invoice_item, item: merchant_3.items.first, quantity: 1, unit_price: 10)
        m3_invoice_item_2 = create(:invoice_item, item: merchant_3.items.second, quantity: 1, unit_price: 10)
        m3_invoice_item_3 = create(:invoice_item, item: merchant_3.items.last, quantity: 6, unit_price: 10)
        create(:transaction, invoice: m3_invoice_item_1.invoice)
        create(:transaction, invoice: m3_invoice_item_2.invoice)
        create(:transaction, invoice: m3_invoice_item_3.invoice)

        merchant_2 = create(:merchant, :with_items, item_count: 1)
        m2_invoice_item = create(:invoice_item, item: merchant_2.items.first, quantity: 9, unit_price: 10)
        create(:transaction, invoice: m2_invoice_item.invoice)

        merchant_4 = create(:merchant, :with_items, item_count: 1)
        m4_invoice_item = create(:invoice_item, item: merchant_4.items.first, quantity: 5, unit_price: 10)
        create(:transaction, invoice: m4_invoice_item.invoice)

        not_expected_merchant = create(:merchant, :with_items, item_count: 1)
        ne_invoice_item = create(:invoice_item, item: not_expected_merchant.items.first, quantity: 1, unit_price: 5)
        create(:transaction, invoice: ne_invoice_item.invoice)

        expect(Merchant.top_5_merchants_revenue).to eq([merchant_1, merchant_2, merchant_3, merchant_4, merchant_5])

        expect(Merchant.top_5_merchants_revenue).to_not include(not_expected_merchant)
      end
    end
  end

  describe 'instance methods' do
    describe '#merchant_best_day' do
      it 'can get the best day for revenue for the top 5 merchants by revenue' do
        merchant = create(:merchant, :with_items, item_count: 3)

        best_invoice = create(:invoice, :with_transactions, created_at: '2000-01-01 15:15:15 UTC')
        create(:invoice_item, item: merchant.items.first, invoice: best_invoice, quantity: 20, unit_price: 10)
        create(:invoice_item, item: merchant.items.second, invoice: best_invoice, quantity: 5, unit_price: 10)

        middle_invoice = create(:invoice, :with_transactions, created_at: '2000-02-02 10:20:30 UTC')
        create(:invoice_item, item: merchant.items.second, invoice: middle_invoice, quantity: 30, unit_price: 10)

        worst_invoice = create(:invoice, :with_transactions, created_at: '2000-03-03 10:10:10 UTC')
        create(:invoice_item, item: merchant.items.first, invoice: worst_invoice, quantity: 10, unit_price: 10)

        expect(merchant.merchant_best_day).to eq('2000-02-02 00:00:00.000000000 +0000')
      end
    end

    describe '#top_five_items' do
      it 'can return the top five revenue earning items for a merchant' do
        merchant = create(:merchant)
        invoice_1 = create(:invoice, :with_transactions)
        invoice_2 = create(:invoice, :with_transactions)

        bad_transaction = create(:transaction, result: false)
        invoice_3 = bad_transaction.invoice

        item_3 = create(:item, unit_price: 10, merchant: merchant)
        create(:invoice_item, item: item_3, invoice: invoice_1, quantity: 5)
        create(:invoice_item, item: item_3, invoice: invoice_2, quantity: 10)
        create(:invoice_item, item: item_3, invoice: invoice_3, quantity: 100)

        item_1 = create(:item, unit_price: 10, merchant: merchant)
        create(:invoice_item, item: item_1, invoice: invoice_1, quantity: 20)
        create(:invoice_item, item: item_1, invoice: invoice_2, quantity: 5)

        item_2 = create(:item, unit_price: 20, merchant: merchant)
        create(:invoice_item, item: item_2, invoice: invoice_1, quantity: 10)

        item_5 = create(:item, unit_price: 1, merchant: merchant)
        create(:invoice_item, item: item_5, invoice: invoice_1, quantity: 50)
        create(:invoice_item, item: item_5, invoice: invoice_2, quantity: 10)

        item_4 = create(:item, unit_price: 5, merchant: merchant)
        create(:invoice_item, item: item_4, invoice: invoice_2, quantity: 20)

        worst_item = create(:item, unit_price: 1, merchant: merchant)
        create(:invoice_item, item: worst_item, invoice: invoice_1, quantity: 5)

        expected = [item_1, item_2, item_3, item_4, item_5]

        expect(merchant.top_five_items).to eq(expected)
        expect(merchant.top_five_items).to_not include(worst_item)
      end
    end

    describe '#ready_to_ship' do
      it 'can give all invoices that are ready to ship ordered by oldest first' do
        merchant = create(:merchant, :with_items, item_count: 4)
        customer = create(:customer)

        invoice_1 = create(:invoice, customer: customer, created_at: '2018-02-13 14:53:59 UTC')
        invoice_2 = create(:invoice, customer: customer, created_at: '2015-05-25 14:53:59 UTC')
        invoice_3 = create(:invoice, customer: customer, created_at: '2010-01-24 14:53:59 UTC')
        invoice_4 = create(:invoice, customer: customer, created_at: '2015-05-25 14:53:59 UTC')

        create(:invoice_item, invoice: invoice_1, item: merchant.items.first, status: 'packaged')
        create(:invoice_item, invoice: invoice_2, item: merchant.items.second, status: 'pending')
        create(:invoice_item, invoice: invoice_3, item: merchant.items.third, status: 'packaged')
        create(:invoice_item, invoice: invoice_4, item: merchant.items.fourth, status: 'shipped')

        actual = merchant.ready_to_ship.map do |invoice_item|
          invoice_item.invoice.created_at
        end

        expected = [invoice_3, invoice_2, invoice_1].map do |invoice|
          invoice.created_at
        end

        expect(actual).to eq(expected)
      end
    end
  end
end
