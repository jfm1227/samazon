class AddSessionIdToShoppingCart < ActiveRecord::Migration[5.2]
  def change
    add_column :shopping_carts, :session_id, :string
  end
end
