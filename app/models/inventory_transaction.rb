class InventoryTransaction < ApplicationRecord
  include InventoryTransactionAasm

  class InvalidTransactionStatusError < StandardError; end
  class InsufficientStockError < StandardError; end
  class InsufficientBaseStockError < StandardError; end

  belongs_to :ingredient

  enum :kind, { addition: 0, substraction: 1 }

  validates :kind, :status, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  def apply!
    if self.completed?
      raise InvalidTransactionStatusError, "the transaction was already completed"
    end

    stored_quantity = if addition?
      ingredient.stored_quantity + quantity
    else
      ingredient.stored_quantity - quantity
    end

    base_ingredient_kind = addition? ? :substraction : :addition
    base_ingredient_update = Ingredients::UpdateInventoryForBaseIngredients.new(
      ingredient, base_ingredient_kind
    )

    ActiveRecord::Base.transaction do
      begin
        base_ingredient_update.call
        ingredient.update!(stored_quantity: stored_quantity)
        self.complete!
      rescue ActiveRecord::RecordInvalid, InsufficientBaseStockError => e
        error_msg = "Insufficient stock. Error: #{e.message}"
        update(error_message: error_msg)
        raise InsufficientStockError, error_msg
      end
    end
    if base_ingredient_update.succeeded?
      CreateInventoryTransactionsJob.perform_later(
        base_ingredient_update.inventory_transactions_params
      )
      update(error_message: nil) if error_message.present?
    end
  end
end
