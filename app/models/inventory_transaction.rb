class InventoryTransaction < ApplicationRecord
  class InvalidTransactionStatusError < StandardError; end

  include InventoryTransactionAasm

  belongs_to :ingredient

  enum :kind, { addition: 0, substraction: 1 }

  validates :kind, :status, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  def apply!
    if self.completed?
      raise InvalidTransactionStatusError, "the transaction was already completed"
    end

    stored_quantity = if self.addition?
      ingredient.stored_quantity + quantity
    else
      ingredient.stored_quantity - quantity
    end

    ActiveRecord::Base.transaction do
      ingredient.update!(stored_quantity: stored_quantity)
      self.complete!
    end
  end
end
