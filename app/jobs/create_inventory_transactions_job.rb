class CreateInventoryTransactionsJob < ApplicationJob
  queue_as :inventory

  def perform(*args, params_data)
    return unless params_data.present?

    params_data.each do |params|
      InventoryTransaction.create!(params)
    end
  end
end
