module OrderProducts
  class UpdateInventoryOnDestruction < BaseUpdateInventory
    private

    def guard
      @order_product.inventoried? && (@order_product.requested? || @order_product.prepare?)
    end

    def order_product_transaction = @order_product.destroy!

    def new_stock_quantity(stored, required) = stored + required

    def kind = :addition
  end
end
