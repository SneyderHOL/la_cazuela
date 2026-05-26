module OrderProductAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :requested, initial: true
      state :prepare, :preparing, :completed

      event :ready_to_cook do
        transitions from: :requested, to: :prepare
      end

      event :cook do
        transitions from: :prepare, to: :preparing
      end

      event :complete do
        transitions to: :completed
      end
    end
  end
end
