module OrderAasm
  extend ActiveSupport::Concern
  included do
    include AASM

    aasm column: "status" do
      state :opened, initial: true
      state :processing, :completed, :closed

      event :process do
        transitions from: :opened, to: :processing
      end

      event :complete do
        transitions from: :processing, to: :completed
      end

      event :close do
        transitions from: :completed, to: :closed
      end
    end
  end
end
