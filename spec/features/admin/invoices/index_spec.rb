require 'rails_helper'

RSpec.describe 'the admin invoice index', :vcr do

  describe 'display' do
    it 'lists all invoice ids in the system' do
      5.times do
        create(:invoice)
      end

      visit admin_invoices_path

      Invoice.all.each do |invoice|
        expect(page).to have_content(invoice.id)
      end
    end
  end

  describe 'hyperlinks' do
    it 'has links for each invoice id that link to respective show pages' do\
      5.times do
        create(:invoice)
      end

      visit admin_invoices_path

      Invoice.all.each do |invoice|
        expect(page).to have_link("#{invoice.id}")

        click_on("#{invoice.id}")

        expect(current_path).to eq(admin_invoice_path(invoice.id))

        visit admin_invoices_path
      end
    end
  end
end
