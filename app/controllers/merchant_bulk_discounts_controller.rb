class MerchantBulkDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @holidays = api_holidays
  end

  def show
  end

  private

  def api_holidays
    json = NagerService.new.holidays
    Holiday.new(json).names_and_dates
  end
end
