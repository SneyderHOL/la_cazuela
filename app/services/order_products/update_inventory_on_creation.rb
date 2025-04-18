module OrderProducts
  class UpdateInventoryOnCreation < BaseUpdateInventory
    private

    def guard = @order_product.product.recipe && @order_product.new_record?

    def order_product_transaction = @order_product.save!

    def new_stock_quantity(stored, required) = stored - required

    def kind = :substraction

    def update_inventory_result = @result = @order_product.persisted?
  end
end
