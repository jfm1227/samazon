# frozen_string_literal: true

class Product < ApplicationRecord
  extend DisplayList

  has_one_attached :image

  belongs_to :category

  scope :on_category, -> (category) { where(category_id: category) }
  scope :sort_order, -> (order) { order(order) }

  scope :category_products, -> (category) {
    on_category(category)
  }

  scope :search_for_id_and_name, -> (keyword) {
    where("name LIKE ?", "%#{keyword}%").or(where("id LIKE ?", "%#{keyword}%"))
  }

  scope :sort_products, -> (sort_order) {
    on_category(sort_order[:sort_category]).sort_order(sort_order[:sort])
  }

  scope :sort_list, -> {
    {
      "並び替え" => "",
      "価格の安い順" => "price asc",
      "価格の高い順" => "price desc",
      "出品の古い順" => "updated_at asc",
      "出品の新しい順" => "updated_at desc"
    }
  }

  scope :recommend_products, -> (number) { where(recommended_flag: true).take(number) }
  scope :recently_products, -> (number) { order(created_at: "desc").take(number) }

  def self.import_csv(file)
    new_products = []
    update_products = []
    CSV.foreach(file.path, headers: true, encoding: "Shift_JIS:UTF-8") do |row|
      row_to_hash = row.to_hash

      if row_to_hash[:id].present?
        update_product = find(id: row_to_hash[:id])
        update_product.attributes = row.to_hash.slice!(csv_attributes)
        update_products << update_product
      else
        new_product = new
        new_product.attributes = row.to_hash.slice!(csv_attributes)
        new_products << new_product
      end
    end
    if update_products.present?
      import update_products, on_duplicate_key_update: csv_attributes
    elsif new_products.present?
      import new_products
    end
  end

  private

  def self.csv_attributes
    [:name, :description, :price, :recommended_flag, :carriage_flag]
  end
end
