module OrderAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :opened, initial: true
      state :processing, :packed, :completed

      event :process do
        after do
          ready_to_cook_order_products
        end
        transitions from: :opened, to: :processing
      end

      event :pack do
        after do
          complete_order_products
        end
        transitions from: :processing, to: :packed
      end

      event :complete do
        after do
          complete_order_products
        end
        transitions from: %i[ processing packed ], to: :completed
      end
    end
  end
end
