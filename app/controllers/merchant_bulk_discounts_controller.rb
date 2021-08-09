class MerchantBulkDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @holidays = api_holidays
  end

  def show
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    bulk_discount = BulkDiscount.new(bulk_discount_params)

    if bulk_discount.save
      redirect_to merchant_bulk_discounts_path(params[:merchant_id])
    else
      redirect_to new_merchant_bulk_discount_path(params[:merchant_id])
      flash[:alert] = "Error: #{error_message(bulk_discount.errors)}"
    end
  end

  private

  def bulk_discount_params
    params.permit(:discount, :quant_threshold, :merchant_id)
  end

  def api_holidays
    json = NagerService.new.holidays
    Holiday.new(json).names_and_dates
  end
end
