class Order < ApplicationRecord
  include OrderAasm

  validates :status, presence: true
end
