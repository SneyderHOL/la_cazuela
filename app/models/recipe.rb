class Recipe < ApplicationRecord
  include AASM

  aasm column: "status" do
    state :declined, initial: true
    state :approved

    event :approve do
      transitions from: :declined, to: :approved
    end

    event :decline do
      transitions from: :approved, to: :declined
    end
  end

  validates :name, :status, presence: true
end
