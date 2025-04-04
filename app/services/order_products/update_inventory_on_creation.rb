class OrderProducts::UpdateInventoryOnCreation
  def initialize(order_product)
    @order_product = order_product
    @inventory_transactions_params = []
    @result = false
  end

  def call
    return unless @order_product.product.recipe && @order_product.new_record?

    update_inventory
    create_inventory_transactions
  rescue ActiveRecord::RecordInvalid
    Rails.logger.error("Failed update Inventory for order_product id #{@order_product.id}")
  end

  def succeeded?
    @result
  end

  private

  def update_inventory
    Rails.logger.info("Updating Inventory for order_product id #{@order_product.id}")
    ActiveRecord::Base.transaction do
      @order_product.save

      @order_product.product.recipe.ingredient_recipes.each do |ingredient_recipe|
        ingredient_recipe.ingredient.update!(
          stored_quantity: ingredient_recipe.ingredient.stored_quantity -
            ingredient_recipe.required_quantity
        )
        @inventory_transactions_params << {
          ingredient_id: ingredient_recipe.ingredient_id,
          quantity: ingredient_recipe.required_quantity,
          kind: :substraction,
          status: "completed"
        }
      end
    end
    @result = @order_product.persisted?
  end

  def create_inventory_transactions
    ::CreateInventoryTransactionsJob.perform_later(@inventory_transactions_params)
  end
end
