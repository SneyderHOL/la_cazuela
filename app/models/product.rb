class Product < ApplicationRecord
  has_one :recipe
  has_many :order_products
  has_many :orders, through: :order_products

  enum :kind, { dish: 0, beverage: 1, packing: 2 }

  validates :name, :kind, presence: true
  validates :active, exclusion: [ nil ]
end
