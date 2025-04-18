class CreateInventoryTransactionJob < ApplicationJob
  queue_as :inventory

  def perform(inventory_transaction_data)
    return unless inventory_transaction_data.present?

    InventoryTransaction.create!(inventory_transaction_data)
  end
end
