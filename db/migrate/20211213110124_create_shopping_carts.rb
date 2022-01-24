class CreateShoppingCarts < ActiveRecord::Migration[5.2]
  def change
    create_table :shopping_carts do |t|
      t.boolean :buy_flag, null: false, default: false
      t.integer :user_id

      t.timestamps
    end

    add_index :shopping_carts, :user_id
  end
end
