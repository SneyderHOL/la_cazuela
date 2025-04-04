module OrderProductAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :to_prepare, initial: true
      state :preparing, :completed

      event :prepare do
        transitions from: :to_prepare, to: :preparing
      end

      event :complete do
        transitions to: :completed
      end
    end
  end
end
