module AllocationAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :available, initial: true
      state :busy, :on_hold, :cleaning

      event :take do
        transitions from: %i[ available on_hold cleaning ], to: :busy
      end

      event :reserve do
        transitions from: %i[ available cleaning ], to: :on_hold
      end

      event :clean do
        transitions from: %i[ available on_hold ], to: :cleaning
        transitions from: :busy, to: :cleaning, guard: :has_no_current_orders?
      end

      event :free do
        transitions from: %i[ available on_hold cleaning ], to: :available
        transitions from: :busy, to: :available, guard: :has_no_current_orders?
      end
    end
  end
end
