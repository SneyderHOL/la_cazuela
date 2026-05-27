module SellOrderAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :opened, initial: true
      state :packed, :invoicing, :delivering, :closed

      event :pack do
        transitions from: :opened, to: :packed
      end

      event :invoice do
        after do
          create_bill
        end
        transitions from: %i[ opened packed delivering ], to: :invoicing
      end

      event :deliver do
        transitions from: %i[ packed invoicing ], to: :delivering, guard: :delivery_allocation?
      end

      event :close do
        after do
          complete_orders
          create_bill
        end
        transitions from: %i[ opened delivering invoicing], to: :closed, guard: :enable_to_close?
      end
    end
  end
end
