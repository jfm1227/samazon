# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :favorite]

  def index
    products = Product.all

    if sort_params.present?
      @category = Category.request_category(sort_params[:sort_category])
      products = products.sort_products(sort_params)
    end

    if params[:category].present?
      @category = Category.request_category(params[:category])
      products = products.category_products(@category)
    end

    products = products.where('name LIKE ?', "%#{params[:keyword]}%") if params[:keyword].present?

    @products = products.display_list(params[:page])

    @categories = Category.all
    @major_category_names = Category.major_categories
    @sort_list = Product.sort_list
  end

  def show
    @product = Product.find(params[:id])
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_url
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :category_id)
  end

  def sort_params
    params.permit(:sort, :sort_category)
  end
end
