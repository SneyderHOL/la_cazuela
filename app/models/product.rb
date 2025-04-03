class Product < ApplicationRecord
  has_one :recipe

  enum :kind, { dish: 0, beverage: 1, packing: 2 }

  validates :name, :kind, presence: true
  validates :active, exclusion: [ nil ]
end
