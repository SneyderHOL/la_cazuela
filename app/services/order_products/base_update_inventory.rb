module OrderProducts
  class BaseUpdateInventory
    def initialize(order_product)
      @order_product = order_product
      @inventory_transactions_params = []
      @result = false
    end

    def call
      return unless guard

      update_inventory!
      update_inventory_result
      create_inventory_transactions
    rescue ActiveRecord::RecordInvalid
      Rails.logger.error(
        "Failed update Inventory for order_id #{@order_product.order_id} & product_id "\
        "#{@order_product.product_id}"
      )
    end

    def succeeded? = @result

    private

    def guard = false

    def order_product_transaction = false

    def create_inventory_transactions
      return unless succeeded?

      ::CreateInventoryTransactionsJob.perform_later(@inventory_transactions_params)
    end

    def new_stock_quantity(stored, required) = stored

    def kind = nil

    def update_inventory_result = false

    def update_inventory!
      Rails.logger.info(
        "Updating Inventory for order_id #{@order_product.order_id} & product_id "\
        "#{@order_product.product_id}"
      )

      ActiveRecord::Base.transaction do
        order_product_transaction

        @order_product.product.recipe.ingredient_recipes.each do |ingredient_recipe|
          required = ingredient_recipe.required_quantity * @order_product.quantity
          stock = new_stock_quantity(ingredient_recipe.ingredient.stored_quantity, required)

          ingredient_recipe.ingredient.update!(stored_quantity: stock)

          @inventory_transactions_params << {
            ingredient_id: ingredient_recipe.ingredient_id,
            quantity: required,
            kind: kind,
            status: "completed"
          }
        end
      end
    end
  end
end
