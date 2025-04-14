module Ingredients
  class UpdateInventoryForBaseIngredients
    VALID_KIND_VALUES = %i[ addition substraction ].freeze

    attr_reader :inventory_transactions_params

    def initialize(base_ingredient, kind)
      @base_ingredient = base_ingredient
      @kind = kind
      @inventory_transactions_params = []
      @result = false
    end

    def call
      return unless @base_ingredient.base? && @base_ingredient.recipe && VALID_KIND_VALUES.include?(@kind)

      update_inventory!
    end

    def succeeded?
      @result
    end

    private

    def update_inventory!
      Rails.logger.info("Updating Inventory for base_ingredient id #{@base_ingredient.id}")
      ActiveRecord::Base.transaction do
        @base_ingredient.recipe.ingredient_recipes.each do |ingredient_recipe|
          new_stock = if @kind == :addition
            ingredient_recipe.ingredient.stored_quantity + ingredient_recipe.required_quantity
          else
            ingredient_recipe.ingredient.stored_quantity - ingredient_recipe.required_quantity
          end

          begin
            ingredient_recipe.ingredient.update!(stored_quantity: new_stock)
          rescue  ActiveRecord::RecordInvalid => e
            error_message = "#{e.message} for ingredient #{ingredient_recipe.ingredient.name}"
            raise InventoryTransaction::InsufficientBaseStockError, error_message
          end

          @inventory_transactions_params << {
            ingredient_id: ingredient_recipe.ingredient_id,
            quantity: ingredient_recipe.required_quantity,
            kind: @kind,
            status: "completed"
          }
        end
      end
      @result = true
    end
  end
end
