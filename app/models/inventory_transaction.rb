# == Schema Information
#
# Table name: inventory_transactions
# Database name: primary
#
#  id            :bigint           not null, primary key
#  by_admin      :boolean          default(FALSE), not null
#  cost          :integer          default(0), not null
#  error_message :string
#  kind          :integer          not null
#  quantity      :integer          not null
#  status        :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ingredient_id :bigint           not null
#
# Indexes
#
#  index_inventory_transactions_on_ingredient_id  (ingredient_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => ingredients.id)
#
class InventoryTransaction < ApplicationRecord
  include InventoryTransactionAasm

  class InvalidTransactionStatusError < StandardError; end
  class InsufficientStockError < StandardError; end
  class InsufficientBaseStockError < StandardError; end

  COP_CURRENCY_FACTOR = 100.0
  belongs_to :ingredient

  enum :kind, { addition: 0, substraction: 1 }

  validates :kind, :status, presence: true
  validates :quantity, :cost, numericality: { greater_than: 0 }

  def apply!
    if self.completed?
      raise InvalidTransactionStatusError, "the transaction was already completed"
    end

    if addition?
      stored_quantity = ingredient.stored_quantity + quantity
      cost = ingredient.cost + self.cost
    else
      stored_quantity = ingredient.stored_quantity - quantity
      cost = ingredient.cost - self.cost
    end

    base_ingredient_kind = addition? ? :substraction : :addition
    base_ingredient_update = Ingredients::UpdateInventoryForBaseIngredients.new(
      ingredient, base_ingredient_kind
    )

    ActiveRecord::Base.transaction do
      begin
        base_ingredient_update.call
        ingredient.update!(stored_quantity: stored_quantity, cost: cost)
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
