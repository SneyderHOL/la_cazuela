module OrderAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :opened, initial: true
      state :processing, :completed, :closed

      event :process do
        after do
          prepare_order_products
        end
        transitions from: :opened, to: :processing
      end

      event :complete do
        after do
          complete_order_products
        end
        transitions from: :processing, to: :completed
      end

      event :close do
        after do
          close_suborders
          complete_order_products
        end
        transitions from: %i[ processing completed ], to: :closed
      end
    end
  end
end
