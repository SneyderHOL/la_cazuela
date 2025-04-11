module IngredientAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :available, initial: true
      state :unavailable, :scarce

      event :able do
        transitions from: %i[ unavailable scarce ], to: :available
      end

      event :disable do
        transitions from: %i[ available scarce ], to: :unavailable
      end

      # TODO: threshold logic to update status to scarce
      event :running_out do
        transitions from: :available, to: :scarce
      end
    end
  end
end
