module IngredientAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :available, initial: true
      state :unavailable

      event :able do
        transitions from: :unavailable, to: :available
      end

      event :disable do
        transitions from: :available, to: :unavailable
      end
    end
  end
end
