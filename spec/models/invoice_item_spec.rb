require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe 'relationships' do
    it { should belong_to(:item) }
    it { should belong_to(:invoice) }
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
end
