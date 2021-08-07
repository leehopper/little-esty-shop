require 'rails_helper'

RSpec.describe 'the admin dashboard', :vcr do
  before :each do
    visit admin_path
  end

  describe 'display' do
    it 'can show the header of the index page' do
      expect(page).to have_content("Admin Dashboard")
    end

    it 'shows the links to the admin merchants and the admin invoices' do
      expect(page).to have_link("Merchants: Index page")
      expect(page).to have_link("Invoices: Index page")
    end

    it 'can click on the index links and be on that specified index page' do

      click_link("Merchants: Index page")
      expect(current_path).to eq("/admin/merchants")

      visit admin_path

      click_link("Invoices: Index page")
      expect(current_path).to eq("/admin/invoices")
    end

    it 'shows customer names with most successful transaction in order most to least and with their number of successful transactions' do
      customer_with_3 = create(:customer)
      customer_with_1 = create(:customer)
      customer_with_5 = create(:customer)
      customer_with_7 = create(:customer)
      customer_with_2 = create(:customer)
      customer_with_4 = create(:customer)

      create(:invoice, :with_transactions, transaction_count: 3, customer: customer_with_3)
      create(:invoice, :with_transactions, transaction_count: 1, customer: customer_with_1)
      create(:invoice, :with_transactions, transaction_count: 5, customer: customer_with_5)
      create(:invoice, :with_transactions, transaction_count: 7, customer: customer_with_7)
      create(:invoice, :with_transactions, transaction_count: 2, customer: customer_with_2)
      create(:invoice, :with_transactions, transaction_count: 4, customer: customer_with_4)

      visit admin_path

      first = find("##{customer_with_7.id}")
      second = find ("##{customer_with_5.id}")
      third = find("##{customer_with_4.id}")
      fourth = find("##{customer_with_3.id}")
      fifth = find("##{customer_with_2.id}")

      expect(first).to appear_before(second)
      expect(second).to appear_before(third)
      expect(third).to appear_before(fourth)
      expect(fourth).to appear_before(fifth)


      within("##{customer_with_7.id}") do
        expect(page).to have_content("#{customer_with_7.first_name}")
        expect(page).to have_content("#{customer_with_7.last_name}")
        expect(page).to have_content("#{customer_with_7.num_success_trans}")
      end


      within("##{customer_with_5.id}") do
        expect(page).to have_content("#{customer_with_5.first_name}")
        expect(page).to have_content("#{customer_with_5.last_name}")
        expect(page).to have_content("#{customer_with_5.num_success_trans}")
      end

      within("##{customer_with_4.id}") do
        expect(page).to have_content("#{customer_with_4.first_name}")
        expect(page).to have_content("#{customer_with_4.last_name}")
        expect(page).to have_content("#{customer_with_4.num_success_trans}")
      end

      within("##{customer_with_3.id}") do
        expect(page).to have_content("#{customer_with_3.first_name}")
        expect(page).to have_content("#{customer_with_3.last_name}")
        expect(page).to have_content("#{customer_with_3.num_success_trans}")
      end

      within("##{customer_with_2.id}") do
        expect(page).to have_content("#{customer_with_2.first_name}")
        expect(page).to have_content("#{customer_with_2.last_name}")
        expect(page).to have_content("#{customer_with_2.num_success_trans}")
      end
    end

    it 'shows list of incomplete invoices by id in ascending order' do
      third_invoice  = create(:invoice, :with_pending_invoice_items, created_at: '2018-02-13 14:53:59 UTC')
      fourth_invoice = create(:invoice, :with_pending_invoice_items, created_at: '2020-02-13 14:53:59 UTC')
      second_invoice = create(:invoice, :with_packaged_invoice_items, created_at: '2015-02-13 14:53:59 UTC')
      first_invoice  = create(:invoice, :with_mixed_status_invoice_items, created_at: '2013-02-13 14:53:59 UTC')

      shipped_only_invoice = create(:invoice, :with_shipped_invoice_items)

      visit admin_path

      expect(page).to have_content("Incomplete Invoices")

      within("#Incomplete_Invoices") do
        expect(page).to have_content("#{first_invoice.id}")
        expect(page).to have_content("#{second_invoice.id}")
        expect(page).to have_content("#{third_invoice.id}")
        expect(page).to have_content("#{fourth_invoice.id}")

        expect(page).to have_content("#{first_invoice.created_at.strftime("%A, %B %d, %Y")}")
        expect(page).to have_content("#{second_invoice.created_at.strftime("%A, %B %d, %Y")}")
        expect(page).to have_content("#{third_invoice.created_at.strftime("%A, %B %d, %Y")}")
        expect(page).to have_content("#{fourth_invoice.created_at.strftime("%A, %B %d, %Y")}")

        expect(page).to_not have_content("#{shipped_only_invoice.id}")
        expect(page).to_not have_content("#{shipped_only_invoice.id}")

        expect("#{first_invoice.id}").to appear_before("#{second_invoice.id}")
        expect("#{second_invoice.id}").to appear_before("#{third_invoice.id}")
        expect("#{third_invoice.id}").to appear_before("#{fourth_invoice.id}")
      end
    end

    it 'links incomplete invoice ids to admin show page' do
      first_invoice  = create(:invoice, :with_mixed_status_invoice_items, created_at: '2013-02-13 14:53:59 UTC')

      visit admin_path

      click_on("#{first_invoice.id}")

      expect(current_path).to eq(admin_invoice_path(first_invoice.id))
    end

  end
end
