require 'rails_helper'

RSpec.describe Customer do
  describe 'relationships' do
    it { should have_many(:invoices) }
  end

  describe 'validations' do
    context ':first_name' do
      it { should validate_presence_of(:first_name) }
    end

    context ':last_name' do
      it { should validate_presence_of(:first_name) }
    end
  end

  describe 'class_methods' do
    describe '#top_5_customers' do
      it 'returns top 5 customers with most number of successful transactions' do
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

        expected = [customer_with_7, customer_with_5, customer_with_4, customer_with_3, customer_with_2].map do |customer|
          customer.first_name
        end

        actual = Customer.top_5_customers.map do |customer|
          customer.first_name
        end

        expect(expected).to eq(actual)
      end
    end
  end
  describe 'instance methods' do
    describe '.num_success_trans' do
      it 'returns number of successful transactions' do
        invoice1 = create(:invoice, :with_transactions, transaction_count: 4)
        invoice2 = create(:invoice, :with_transactions, transaction_count: 6)
        create(:transaction, result: false, invoice: invoice2)
        create(:invoice, :with_transactions, transaction_count: 2, customer: invoice2.customer)

        expect(invoice1.customer.num_success_trans).to eq(4)
        expect(invoice2.customer.num_success_trans).to eq(8)
      end
    end
  end
end
