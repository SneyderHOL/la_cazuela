module AllocationAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :available, initial: true
      state :busy, :on_hold

      event :take do
        transitions from: %i[ available on_hold ], to: :busy
      end

      event :free do
        transitions to: :available
      end
    end
  end
end
