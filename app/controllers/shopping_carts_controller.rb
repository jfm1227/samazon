class ShoppingCartsController < ApplicationController
  SETTLEMENT_AMOUNT_RANGE = 50..9_999_999.freeze

  before_action :set_cart, only: %i[index create destroy remove_shopping_cart_item]

  def index
    @shopping_cart_items = ShoppingCartItem.user_cart_items(@shopping_cart)
    total = @shopping_cart.total.fractional / 100
    @is_available_buy = SETTLEMENT_AMOUNT_RANGE.include?(total)
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
    total = @shopping_cart.total.fractional / 100
    raise '決済可能な金額ではありません' unless SETTLEMENT_AMOUNT_RANGE.include?(total)

    Payjp.api_key = ENV['PAYJP_PUBLIC_KEY']
    Payjp::Charge.create(
      amount: total,
      card: params['payjp-token'],
      currency: 'jpy'
    )
    @shopping_cart.buy_flag = true
    @shopping_cart.save
    redirect_to cart_users_url
  end

  def remove_shopping_cart_item
    @product = Product.find_by(id: params[:product_id])
    quantity = ShoppingCartItem.user_cart_items(@shopping_cart).find_by(item_id: @product.id).quantity
    @shopping_cart.remove(@product, quantity)
    redirect_to cart_users_path
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
