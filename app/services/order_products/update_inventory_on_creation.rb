module OrderProducts
  class UpdateInventoryOnCreation < BaseUpdateInventory
    private

    def guard
      initiate_order_product_processing
      !@order_product.inventoried? && @order_product.requested?
    end

    def initiate_order_product_processing
      @order_product.inventoried = false if @order_product.inventoried.nil?
    end

    def order_product_transaction = @order_product.update!(inventoried: true)

    def new_stock_quantity(stored, required) = stored - required

    def kind = :substraction
  end
end
