require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe 'relationships' do
    it { should belong_to(:item) }
    it { should belong_to(:invoice) }
    it { should have_many(:bulk_discounts).through(:item) }
  end

  describe 'enum status' do
    it { should define_enum_for(:status).with_values([:pending, :packaged, :shipped]) }
  end

  describe 'class methods' do
    describe '.locate' do
      it 'locates invoice item with invoice and item ids' do
        invoice_item = create(:invoice_item)

        expected = InvoiceItem.locate(invoice_item.invoice.id, invoice_item.item.id)

        expect(expected).to eq(invoice_item)
      end
    end

    describe '.total_revenue' do
      it 'calculates total revenue of a collection of invoice items' do
        create(:invoice_item, quantity: 10, unit_price: 100)
        create(:invoice_item, quantity: 20, unit_price: 10)
        create(:invoice_item, quantity: 50, unit_price: 5)

        expect(InvoiceItem.total_revenue).to eq(1450)
      end
    end
  end

  describe 'instance methods' do
    describe '.discount' do
      it 'returns the discount amount for the invoice item' do
        merchant = create(:merchant)
        item_1 = create(:item, merchant: merchant, unit_price: 10)
        create(:bulk_discount, merchant: merchant, discount: 0.2, quant_threshold: 20)
        create(:bulk_discount, merchant: merchant, discount: 0.5, quant_threshold: 50)

        invoice_item_1 = create(:invoice_item, item: item_1, quantity: 10)

        expect(invoice_item_1.discount).to eq(0)

        invoice_item_2 = create(:invoice_item, item: item_1, quantity: 25)

        expect(invoice_item_2.discount).to eq(50)

        invoice_item_3 = create(:invoice_item, item: item_1, quantity: 50)

        expect(invoice_item_3.discount).to eq(250)
      end

      it 'applies the discount with the largest percentage that meets the quantity criteria' do
        merchant = create(:merchant)
        item_1 = create(:item, merchant: merchant, unit_price: 10)
        create(:bulk_discount, merchant: merchant, discount: 0.3, quant_threshold: 20)
        create(:bulk_discount, merchant: merchant, discount: 0.1, quant_threshold: 50)

        invoice_item_1 = create(:invoice_item, item: item_1, quantity: 50)

        expect(invoice_item_1.discount).to eq(150)
      end

      it 'returns discount zero if there are no discounts' do
        merchant = create(:merchant)
        item_1 = create(:item, merchant: merchant, unit_price: 10)
        invoice_item_1 = create(:invoice_item, item: item_1, quantity: 50)

        expect(invoice_item_1.discount).to eq(0)
      end
    end
  end
end
