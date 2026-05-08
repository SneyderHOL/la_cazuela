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

      event :clean do
        transitions from: %i[ available on_hold busy ], to: :cleaning
      end

      event :free do
        transitions to: :available
      end
    end
  end
end
