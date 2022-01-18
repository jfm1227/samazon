class ShoppingCartsController < ApplicationController
  before_action :set_cart, only: %i[index create destroy]

  def index
    @user_cart_items = ShoppingCartItem.user_cart_items(@shopping_cart)
  end

  def show
    @cart = ShoppingCart.find(user_id: current_user)
  end

  def create
    @product = Product.find(product_params[:product_id])
    @shopping_cart.add(@product, product_params[:price].to_i, product_params[:quantity].to_i)
    redirect_to cart_users_path
  end

  def update
  end

  def destroy
    @shopping_cart.buy_flag = true
    @shopping_cart.save
    redirect_to cart_users_url
  end

  private

  def product_params
    params.permit(:product_id, :price, :quantity)
  end

   def set_cart
     @shopping_cart = if defined?(current_user).nil?
                        ShoppingCart.find_or_create_by!(session_id: session.id.to_s, buy_flag: false)
                      else
                        ShoppingCart.find_or_create_by!(user_id: current_user.id, buy_flag: false)
                      end
   end
end
