require 'rails_helper'

RSpec.describe Invoice do
  describe 'relationships' do
    it { should have_many(:transactions) }
    it { should have_many(:invoice_items) }
    it { should belong_to(:customer) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:bulk_discounts).through(:items) }
  end

  describe 'validations' do
    context 'status' do
      it { should validate_presence_of(:status) }
      it { should define_enum_for(:status).with_values([:in_progress, :completed, :cancelled]) }
    end
  end

  describe 'class methods' do
    describe '#incomplete_invoices_by_date' do
      it 'returns list of invoices from old to new with invoice_items that have not been shipped' do
        third_invoice  = create(:invoice, :with_pending_invoice_items, created_at: '2018-02-13 14:53:59 UTC')
        fourth_invoice = create(:invoice, :with_pending_invoice_items, created_at: '2020-02-13 14:53:59 UTC')
        second_invoice = create(:invoice, :with_packaged_invoice_items, created_at: '2015-02-13 14:53:59 UTC')
        first_invoice  = create(:invoice, :with_mixed_status_invoice_items, created_at: '2013-02-13 14:53:59 UTC')

        shipped_only_invoice = create(:invoice, :with_shipped_invoice_items)

        expect(Invoice.incomplete_invoices_by_date).to eq([first_invoice, second_invoice, third_invoice, fourth_invoice])
      end
    end
  end

  describe 'instance methods' do
    describe '.total_revenue' do
      it 'calculates invoice total revenue' do
        invoice = create(:invoice)
        create(:invoice_item, quantity: 100, unit_price: 1000, invoice: invoice)
        create(:invoice_item, quantity: 10, unit_price: 50, invoice: invoice)
        create(:invoice_item, quantity: 30, unit_price: 500, invoice: invoice)

        expect(invoice.invoice_items.count).to eq(3)
        expect(invoice.total_revenue).to eq(115500)
      end
    end

    describe '.total_discount' do
      it 'calculates the total revenue with bulk discounts accounted for' do
        merchant = create(:merchant)
        invoice = create(:invoice)
        item_1 = create(:item, merchant: merchant, unit_price: 5)
        item_2 = create(:item, merchant: merchant, unit_price: 10)
        item_3 = create(:item, merchant: merchant, unit_price: 15)
        create(:invoice_item, item: item_1, invoice: invoice, quantity: 10)
        create(:invoice_item, item: item_2, invoice: invoice, quantity: 25)
        create(:invoice_item, item: item_3, invoice: invoice, quantity: 50)
        create(:bulk_discount, merchant: merchant, discount: 0.2, quant_threshold: 20)
        create(:bulk_discount, merchant: merchant, discount: 0.5, quant_threshold: 50)

        expect(invoice.total_discount).to eq(425)
      end

      it 'returns zero when there are no discounts applied' do
        merchant = create(:merchant)
        invoice = create(:invoice)
        item_1 = create(:item, merchant: merchant, unit_price: 5)
        item_2 = create(:item, merchant: merchant, unit_price: 10)
        item_3 = create(:item, merchant: merchant, unit_price: 15)
        create(:invoice_item, item: item_1, invoice: invoice, quantity: 10)
        create(:invoice_item, item: item_2, invoice: invoice, quantity: 25)
        create(:invoice_item, item: item_3, invoice: invoice, quantity: 50)
        create(:bulk_discount, merchant: merchant, discount: 0.2, quant_threshold: 500)
        create(:bulk_discount, merchant: merchant, discount: 0.5, quant_threshold: 1000)

        expect(invoice.total_discount).to eq(0)

        invoice_2 = create(:invoice)

        expect(invoice_2.total_discount).to eq(0)
      end
    end

    describe '.total_discounted_revenue' do
      it 'returns the total revenue for the invoice with discounts taken into account' do
        merchant = create(:merchant)
        invoice = create(:invoice)
        item_1 = create(:item, merchant: merchant, unit_price: 100)
        item_2 = create(:item, merchant: merchant, unit_price: 10)
        item_3 = create(:item, merchant: merchant, unit_price: 3)
        create(:invoice_item, item: item_1, invoice: invoice, quantity: 5)
        create(:invoice_item, item: item_2, invoice: invoice, quantity: 25)
        create(:invoice_item, item: item_3, invoice: invoice, quantity: 50)
        create(:bulk_discount, merchant: merchant, discount: 0.2, quant_threshold: 20)
        create(:bulk_discount, merchant: merchant, discount: 0.5, quant_threshold: 50)

        expect(invoice.total_revenue).to eq(900)
        expect(invoice.total_discount).to eq(125)
        expect(invoice.total_discounted_revenue).to eq(775)
      end
    end
  end
end
