module InventoryTransactionAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :pending, initial: true
      state :completed

      event :complete do
        transitions from: :pending, to: :completed
      end
    end
  end
end
