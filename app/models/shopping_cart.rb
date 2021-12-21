
class ShoppingCart < ApplicationRecord
  acts_as_shopping_cart
  
  scope :set_user_cart, -> (user) { user_cart = where(user_id: user.id, buy_flag: false)&.last
                              user_cart.nil? ? ShoppingCart.create(user_id: user.id)
                                             : user_cart }

scope :bought_carts, -> { where(buy_flag: true) }
   scope :bought_months_sqlite, -> { bought_carts.order(updated_at: :desc).group("strftime('%Y-%m', updated_at, '+09:00')").pluck(:updated_at) }
   scope :bought_days_sqlite, -> { bought_carts.order(updated_at: :desc).group("strftime('%Y-%m-%d', updated_at, '+09:00')").pluck(:updated_at) }
   scope :bought_months_pg, -> { bought_carts.pluck("distinct(date_trunc('month', updated_at + '9 hours'))").map{ |m| m.in_time_zone('Asia/Tokyo') }.reverse }
   scope :bought_days_pg, -> { bought_carts.pluck("distinct(date_trunc('day', updated_at + '9 hours'))").map{ |d| d.in_time_zone('Asia/Tokyo') }.reverse }
   scope :search_bought_carts_by_month, -> (month) { bought_carts.where(updated_at: month.all_month) }
   scope :search_bought_carts_by_day, -> (day) { bought_carts.where(updated_at: day.all_day) }
   
   scope :search_carts_by_ids, -> (ids) { where("id LIKE ?", "%#{ids}%") }
   scope :search_bought_carts_by_ids, -> (ids) { bought_carts.search_carts_by_ids(ids) }    
   
   scope :sort_list, -> {
     {"日別": "daily", "月別": "month"}
   }
 
   def self.get_monthly_sales
     if Rails.env.production?
       months = bought_months_pg
     else
       months = bought_months_sqlite
     end
     
     array = Array.new(months.count) { Hash.new }
     
     months.each_with_index do |month, i|
       monthly_sales = search_bought_carts_by_month(month)
       total = 0
       
       monthly_sales.each do |monthly_sale|
         total += monthly_sale.total.fractional / 100
       end   
       
       array[i][:period] = month.strftime("%Y-%m")
       array[i][:total] = total
       array[i][:count] = monthly_sales.count
       array[i][:average] = total / monthly_sales.count
     end
     
     return array
   end
 
   def self.get_daily_sales
     if Rails.env.production?
       days = bought_days_pg
     else
       days = bought_days_sqlite
     end    
     
     array = Array.new(days.count) { Hash.new }
     
     days.each_with_index do |day, i|
       daily_sales = search_bought_carts_by_day(day)
       total = 0
       
       daily_sales.each do |daily_sale|
         total += daily_sale.total.fractional / 100
       end
      
       array[i][:period] = day.strftime("%Y-%m-%d")
      array[i][:total] = total
       array[i][:count] = daily_sales.count
       array[i][:average] = total / daily_sales.count
     end
     
     return array
   end

  def tax_pct
    0
  end
end