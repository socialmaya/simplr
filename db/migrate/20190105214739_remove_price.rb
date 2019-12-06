class RemovePrice < ActiveRecord::Migration[5.0]
  def change
    if Rails.env.development?
      remove_column :products, :price
    else
      remove_column :products, :price_cents
      remove_column :products, :price_currency
    end
  end
end
