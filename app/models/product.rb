class Product < ApplicationRecord
  include ActiveScopeable

  belongs_to :category
  has_one :recipe, dependent: :restrict_with_error
  has_many :order_products, dependent: :restrict_with_error
  has_many :orders, through: :order_products

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :active, exclusion: [ nil ]
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :detail, length: { maximum: 300 }, allow_nil: true
end
