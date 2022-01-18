

class Dashboard::OrdersController < ApplicationController
  before_action :authenticate_admin!
  layout "dashboard/dashboard"

  def index
    if params[:code].present?
        @orders = ShoppingCart.search_bought_carts_by_ids(params[:code]).page(params[:page]).per(15)
    else
        @orders = ShoppingCart.bought_carts.page(params[:page]).per(15)
    end   
  end
end