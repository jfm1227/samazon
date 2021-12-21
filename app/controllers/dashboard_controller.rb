class DashboardController < ApplicationController
  before_action :authenticate_admin!, except: :index
  layout 'dashboard/dashboard'

  def index
     @sort = params[:sort]
     @sort_list = ShoppingCart.sort_list 
     
     if @sort == "month"
       sales = ShoppingCart.get_monthly_sales
     else
       sales = ShoppingCart.get_daily_sales
     end
     
     @sales = Kaminari.paginate_array(sales).page(params[:page]).per(15)
  end
end

