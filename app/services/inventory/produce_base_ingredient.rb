module Inventory
  class ProduceBaseIngredient
    class InvalidBaseIngredientError < StandardError; end
    class InvalidProductionQuantityError < StandardError; end
    class InsufficientStockError < StandardError; end

    attr_reader :production_cost

    def initialize(base_ingredient, quantity)
      @base_ingredient = base_ingredient
      @quantity = quantity
      @production_cost = 0
    end

    def call
      validate!
      consume_recipe_ingredients!
      @production_cost
    end

    private

    def validate!
      unless @base_ingredient.base?
        raise InvalidBaseIngredientError, "ingredient #{@base_ingredient.id} must be a base ingredient"
      end
      unless @base_ingredient.recipe.present?
        raise InvalidBaseIngredientError, "base ingredient #{@base_ingredient.id} must have a recipe"
      end
      unless @quantity.positive?
        raise InvalidProductionQuantityError, "production quantity must be greater than zero"
      end
      unless (@quantity % @base_ingredient.recipe.output_quantity).zero?
        raise InvalidProductionQuantityError, "production quantity must be a multiple of recipe output quantity"
      end
    end

    def consume_recipe_ingredients!
      ingredient_recipes.each do |ingredient_recipe|
        ingredient = Ingredient.lock.find(ingredient_recipe.ingredient_id)
        required_quantity = ingredient_recipe.required_quantity * production_multiplier
        consume_ingredient!(ingredient, required_quantity)
      end
    end

    def ingredient_recipes
      @base_ingredient.recipe.ingredient_recipes.sort_by(&:ingredient_id)
    end

    def production_multiplier
      @quantity / @base_ingredient.recipe.output_quantity
    end

    def consume_ingredient!(ingredient, quantity)
      if ingredient.stored_quantity < quantity
        raise InsufficientStockError,
              "#{ingredient.name} has insufficient stock " \
              "(required: #{quantity}, available: #{ingredient.stored_quantity})"
      end

      cost = consumption_cost(ingredient, quantity)
      ingredient.update!(
        stored_quantity: ingredient.stored_quantity - quantity,
        cost: ingredient.cost - cost
      )

      @production_cost += cost

      InventoryTransaction.create!(
        ingredient: ingredient,
        transaction_type: :consumption,
        direction: :subtraction,
        quantity: quantity,
        cost: cost,
        status: :completed,
        by_admin: true
      )
    end

    def consumption_cost(ingredient, quantity)
      (ingredient.unit_cost * quantity).round
    end
  end
end
