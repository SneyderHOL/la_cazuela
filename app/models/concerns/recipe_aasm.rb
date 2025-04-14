module RecipeAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :drafting, initial: true
      state :declined, :approved

      event :approve do
        transitions from: %i[ drafting declined ], to: :approved
      end

      event :decline do
        transitions from: %i[ drafting approved ], to: :declined
      end

      event :draft do
        transitions from: :declined, to: :drafting
      end
    end
  end
end
