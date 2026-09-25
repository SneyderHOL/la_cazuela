module Inventory
  class ConsumeOrderProduct
    class AlreadyConsumedError < StandardError; end
    class MissingRecipeError < StandardError; end
    class InsufficientStockError < StandardError; end

    def initialize(order_product)
      @order_product = order_product
      @inventory_transactions = []
    end

    def call
      validate!

      ActiveRecord::Base.transaction do
        consume_recipe!
        create_inventory_transactions!
        @order_product.update!(inventory_consumed_at: Time.current)
      end

      true
    end

    private

    def validate!
      raise AlreadyConsumedError if @order_product.inventory_consumed_at.present?
      raise MissingRecipeError unless @order_product.recipe.present?
    end

    def consume_recipe!
      ingredient_recipes.each do |ingredient_recipe|
        ingredient = Ingredient.lock.find(ingredient_recipe.ingredient_id)
        required_quantity = ingredient_recipe.required_quantity * @order_product.quantity
        consume_ingredient!(ingredient, required_quantity)
      end
    end

    def ingredient_recipes
      @order_product.recipe.ingredient_recipes.sort_by(&:ingredient_id)
    end

    def consume_ingredient!(ingredient, quantity)
      if ingredient.stored_quantity < quantity
        raise InsufficientStockError, "#{ingredient.name} has insufficient stock"
      end

      cost = calculate_consumption_cost(ingredient, quantity)

      ingredient.update!(
        stored_quantity: ingredient.stored_quantity - quantity,
        cost: ingredient.cost - cost
      )

      @inventory_transactions << {
        ingredient_id: ingredient.id,
        order_product_id: @order_product.id,
        transaction_type: :consumption,
        direction: :subtraction,
        quantity: quantity,
        cost: cost,
        status: :completed
      }
    end

    # consumed_inventory_cost has first been calculated as the value of the quantity being removed
    def calculate_consumption_cost(ingredient, quantity)
      (ingredient.unit_cost * quantity).round
    end

    def create_inventory_transactions!
      InventoryTransaction.create!(@inventory_transactions)
    end
  end
end
