class Ingredient < ApplicationRecord
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

  enum :unit, { ml: 0, mg: 1 }

  validates :name, :unit, :status, presence: true
  validates :stored_quantity, numericality: { only_integer: true }
end
