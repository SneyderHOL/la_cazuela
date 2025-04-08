class CreateInventoryTransactionsJob < ApplicationJob
  queue_as :inventory

  def perform(params_data)
    return unless params_data.present?

    params_data.each { |params| InventoryTransaction.create!(params) }
  end
end
