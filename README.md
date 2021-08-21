# Little Esty Shop

## 1. References
- https://hidden-brook-38464.herokuapp.com/
- 

## 2. Introduction
Little Esty Shop was originally a group project that relies on data from multiple CSV files to track Merchants, Merchant Items, Customers, Invoices, Invoice Items and Transactions. Merchants can sell their items on the application. Those items are added to invoices as invoice items where items from a variety of merchants may be listed. A customer has many invoices which are associated with successful and unsuccessful transactions.

This fork includes a new feature, bulk dicsounts that was individually built as the final project for Module 2 at the Turing School of Software and Design. The project emphasis was on TDD and MVC, not the front end. Full project directions can be found here: https://backend.turing.edu/module2/projects/bulk_discounts

Additionally, the new feature included a full refactor of the original project to implement factory bot and vcr to dry up the testing code and speed up the run time.

Table Statuses:
* Invoice:        in progress, completed, cancelled
* Transactions:   success, fail
* Invoice Items:  pending, packaged, shipped

## 3. Setup

### 3.1 Rails
- Rails 5.2.5

### 3.2 Gems
- rspec
- shoulda-matchers
- orderly
- launchy
- capybara
- simplecov

### 3.4 Database
- PostgreSQL

### 3.5 Rake

- `lib/tasks/csv_load.rake`

```ruby
namespace :csv_load do
desc 'Import all CSV files at once'
task all: [
  "csv_load:customers",
  "csv_load:merchants",
  "csv_load:items",
  "csv_load:invoices",
  "csv_load:invoice_items",
  "csv_load:transactions"
]
end
```

Run the following command to load all data from the CSV files into the database:

`rake csv_load:all`

## 4. Design Schema

![Little Esty Shop Designer Schema](https://dm2301files.storage.live.com/y4mxH6KXS19b0buWvfQ-qvAxYV-pMARoJx4UN_8dScBhdN2OjJfkPEC2A667zHcsfK3g-0CsHo1r78QTfJjFOdDaywtcmUs-wJAfjgWahcjCPdMN8khSg5WsYOf0bGLAm7B1BDrkQEnKy1H7-bffYhFJ4VtWXrycYlntYpY1Ex6PfFN4DrzIRilFH9fZGxTaIK3?width=1262&height=616&cropmode=none)

## 5. API

Application Controller/Classes:

- ApiService
- GithubService < ApiService

  - Repos: endpoint = 'https://api.github.com/repos/gunnarrunner/little-esty-shop'

  - Contributors: endpoint = 'https://api.github.com/repos/gunnarrunner/little-esty-shop/contributors'

  - Merges: endpoint = 'https://api.github.com/repos/gunnarrunner/little-esty-shop/pulls?state=closed'

Pulling In and Formatting Data:
* `response = Faraday.get(endpoint)`
* `data = response.body`
* `JSON.parse(data, symbolize_names: true)`

POROS:
- `repo.rb`
- `contributor.rb`

## 7. Next Steps
- Front end buildout
