module SellOrderAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :opened, initial: true
      state :packed, :delivering, :closed

      event :pack do
        transitions from: :opened, to: :packed
      end

      event :deliver do
        transitions from: :packed, to: :delivering, guard: :delivery_allocation?
      end

      event :close do
        after do
          complete_orders
          create_bill
        end
        transitions from: %i[ opened delivering ], to: :closed
      end
    end
  end
end
