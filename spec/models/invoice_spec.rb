require 'rails_helper'

RSpec.describe Invoice do
  describe 'relationships' do
    it { should have_many(:transactions) }
    it { should have_many(:invoice_items) }
    it { should belong_to(:customer) }
    it { should have_many(:items).through(:invoice_items) }
  end

  describe 'validations' do
    context 'status' do
      it { should validate_presence_of(:status) }
      it { should define_enum_for(:status).with_values([:in_progress, :completed, :cancelled]) }
    end
  end

  it 'calculates invoice total revenue' do
    invoice = create(:invoice)
    create(:invoice_item, quantity: 100, unit_price: 1000, invoice: invoice)
    create(:invoice_item, quantity: 10, unit_price: 50, invoice: invoice)
    create(:invoice_item, quantity: 30, unit_price: 500, invoice: invoice)

    expect(invoice.invoice_items.count).to eq(3)
    expect(invoice.total_revenue).to eq(115500)
  end

  it 'returns list of invoices from old to new with invoice_items that have not been shipped' do
    third_invoice  = create(:invoice, :with_pending_invoice_items, created_at: '2018-02-13 14:53:59 UTC')
    fourth_invoice = create(:invoice, :with_pending_invoice_items, created_at: '2020-02-13 14:53:59 UTC')
    second_invoice = create(:invoice, :with_packaged_invoice_items, created_at: '2015-02-13 14:53:59 UTC')
    first_invoice  = create(:invoice, :with_mixed_status_invoice_items, created_at: '2013-02-13 14:53:59 UTC')

    shipped_only_invoice = create(:invoice, :with_shipped_invoice_items)

    expect(Invoice.incomplete_invoices_by_date).to eq([first_invoice, second_invoice, third_invoice, fourth_invoice])
  end
end
