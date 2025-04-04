class OrderProduct < ApplicationRecord
  include OrderProductAasm

  belongs_to :order
  belongs_to :product
  # does not guarantees referencial integrity - not a foreign_key
  belongs_to :recipe, optional: true

  validates :status, presence: true
  validates :quantity, numericality: { greater_than: 0 }
end
