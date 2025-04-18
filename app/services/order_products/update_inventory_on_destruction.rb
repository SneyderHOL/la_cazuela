module OrderProducts
  class UpdateInventoryOnDestruction < BaseUpdateInventory
    private

    def guard = @order_product.product.recipe && @order_product.persisted?

    def order_product_transaction = @order_product.destroy!

    def new_stock_quantity(stored, required) = stored + required

    def kind = :addition

    def update_inventory_result = @result = !@order_product.persisted?
  end
end
