class Product < ApplicationRecord
  include ActiveScopeable

  has_one :recipe
  has_many :order_products
  has_many :orders, through: :order_products

  enum :kind, { dish: 0, beverage: 1, entry: 2, dessert: 3, aside: 4, packing: 5 }

  validates :name, :kind, presence: true
  validates :active, exclusion: [ nil ]
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :detail, length: { maximum: 300 }, allow_nil: true
end
